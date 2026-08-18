#!/usr/bin/env bash
# Decompile the official Steam SWF into src/, copy game assets and application.xml, and rebuild FRESteamWorks.ane.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$ROOT/src"
ANE_OUT="$ROOT/extensions/FRESteamWorks.ane"
MIME_TYPE="application/vnd.adobe.air-native-extension-package+zip"
EXTENSION_ID="com.amanitadesign.steam.FRESteamWorks"
GAME_DIR="${DUNGEON_RAMPAGE_DIR:-}"
FFDEC="${FFDEC_HOME:-}"

# Steam redistributables live next to the official exe. Copy them into every
# matching ANE platform directory that already exists in the official extension
# (do not create platforms the game did not ship). Same mapping on every OS.
steam_lib_for_platform() {
  case "$1" in
    Windows-x86) echo steam_api.dll ;;
    Windows-x86-64) echo steam_api64.dll ;;
    Linux-x86-64) echo libsteam_api.so ;;
    MacOS-x86-64) echo libsteam_api.dylib ;;
    *) echo "" ;;
  esac
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [--game DIR] [--ffdec PATH]

  --game DIR    Official Dungeon Rampage install directory
                (or set DUNGEON_RAMPAGE_DIR)
  --ffdec PATH  ffdec, ffdec.sh, or ffdec.jar
                (or set FFDEC_HOME to the file or install dir)
                Prefer the dev branch of https://github.com/Tutez64/jpexs-decompiler
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --game)
      GAME_DIR="$2"
      shift 2
      ;;
    --ffdec)
      FFDEC="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

die() {
  echo "error: $*" >&2
  exit 1
}

find_game_dir() {
  local candidates=()
  [[ -n "$GAME_DIR" ]] && candidates+=("$GAME_DIR")
  candidates+=(
    "$HOME/.steam/steam/steamapps/common/DungeonRampage"
    "$HOME/.local/share/Steam/steamapps/common/DungeonRampage"
    "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/DungeonRampage"
    "/usr/share/steam/steamapps/common/DungeonRampage"
  )
  local dir
  for dir in "${candidates[@]}"; do
    if [[ -f "$dir/DungeonBustersProject.swf" ]]; then
      (cd "$dir" && pwd)
      return 0
    fi
  done
  die "Official game not found. Install Dungeon Rampage or pass --game / DUNGEON_RAMPAGE_DIR."
}

normalize_copied() {
  local root="$1"
  if [[ -f "$root" ]]; then
    chmod a-x "$root"
    case "$root" in
      *.as|*.xml|*.json|*.txt|*.md|*.sha256) sed -i 's/\r$//' "$root" ;;
    esac
    return
  fi
  [[ -d "$root" ]] || return 0
  find "$root" -type f -exec chmod a-x {} +
  find "$root" -type f \( -name '*.as' -o -name '*.xml' -o -name '*.json' -o -name '*.txt' -o -name '*.md' -o -name '*.sha256' \) \
    -exec sed -i 's/\r$//' {} +
}

file_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    command -v openssl >/dev/null 2>&1 || die "sha256sum, shasum, or openssl is required"
    openssl dgst -sha256 "$1" | awk '{print $NF}'
  fi
}

find_ffdec() {
  local files=()
  if [[ -n "$FFDEC" ]]; then
    if [[ -f "$FFDEC" ]]; then
      files+=("$FFDEC")
    else
      files+=(
        "$FFDEC/ffdec.sh"
        "$FFDEC/ffdec"
        "$FFDEC/ffdec.jar"
      )
    fi
  fi
  local cmd
  for cmd in ffdec ffdec.sh; do
    if command -v "$cmd" >/dev/null 2>&1; then
      files+=("$(command -v "$cmd")")
    fi
  done
  files+=(
    /usr/share/ffdec/ffdec.sh
    /usr/bin/ffdec
    /opt/ffdec/ffdec.sh
    "$HOME/FFDec/ffdec.sh"
  )
  local file
  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      readlink -f "$file" 2>/dev/null || realpath "$file" 2>/dev/null || echo "$file"
      return 0
    fi
  done
  die "JPEXS FFDec not found. Prefer the dev branch of https://github.com/Tutez64/jpexs-decompiler (fixes for this project may not be in the latest upstream release yet). Pass --ffdec / FFDEC_HOME."
}

run_ffdec() {
  local ffdec_path="$1"
  shift
  export FFDEC_MEMORY="${FFDEC_MEMORY:-2048m}"
  if [[ "$ffdec_path" == *.jar ]]; then
    command -v java >/dev/null 2>&1 || die "java is required to run ffdec.jar"
    java -Xmx2048m -jar "$ffdec_path" "$@"
  else
    "$ffdec_path" "$@"
  fi
}

export_scripts() {
  local ffdec_path="$1"
  local swf_path="$2"
  local export_dir="$3"
  rm -rf "$export_dir"
  mkdir -p "$export_dir"
  echo "Decompiling $swf_path ..."
  run_ffdec "$ffdec_path" \
    -config paramNamesEnable=true \
    -exportembed \
    -exportTimeout 1800 \
    -export script \
    "$export_dir" \
    "$swf_path"
}

install_src() {
  local export_dir="$1"
  local swf_path="$2"
  local scripts="$export_dir/scripts"
  [[ -d "$scripts" ]] || scripts="$export_dir"

  if [[ -z "$(find "$scripts" -name '*.as' -print -quit)" ]]; then
    die "FFDec produced no ActionScript files under $export_dir"
  fi

  # assets.swf is synthesized by FFDec (not a raw dump). Hash the official SWF
  # instead: if those bytes did not change, sprite tags did not change.
  local stamp_name="assets.swf.source.sha256"
  local stamp_file="$ROOT/tools/$stamp_name"
  local assets_keep=""
  local old_stamp=""
  if [[ -d "$SRC_DIR/_assets" ]]; then
    assets_keep="$(mktemp -d "${TMPDIR:-/tmp}/dr-assets.XXXXXX")"
    cp -a "$SRC_DIR/_assets" "$assets_keep/_assets"
  fi
  if [[ -f "$stamp_file" ]]; then
    old_stamp="$(tr -d '[:space:]' < "$stamp_file")"
  fi
  local new_stamp
  new_stamp="$(file_sha256 "$swf_path")"

  rm -rf "$SRC_DIR"
  mkdir -p "$SRC_DIR"
  cp -a "$scripts"/. "$SRC_DIR"/

  local keep_assets=0
  if [[ -n "$assets_keep" && -f "$assets_keep/_assets/assets.swf" ]]; then
    if [[ -z "$old_stamp" || "$old_stamp" == "$new_stamp" ]]; then
      keep_assets=1
    fi
  fi

  rm -rf "$SRC_DIR/_assets"
  if [[ "$keep_assets" -eq 1 ]]; then
    cp -a "$assets_keep/_assets" "$SRC_DIR/_assets"
    echo "Keeping src/_assets (official SWF hash unchanged)"
  elif [[ -d "$export_dir/_assets" ]]; then
    cp -a "$export_dir/_assets" "$SRC_DIR/_assets"
    echo "Updating src/_assets from FFDec (official SWF changed)"
  elif [[ -n "$assets_keep" ]]; then
    cp -a "$assets_keep/_assets" "$SRC_DIR/_assets"
  fi
  [[ -n "$assets_keep" ]] && rm -rf "$assets_keep"

  if [[ -d "$SRC_DIR/_assets" ]]; then
    printf '%s\n' "$new_stamp" > "$stamp_file"
    normalize_copied "$stamp_file"
  fi
  normalize_copied "$SRC_DIR"
}

is_git_lfs_pointer() {
  local path="$1"
  [[ -f "$path" ]] || return 1
  [[ "$(wc -c < "$path")" -le 1024 ]] || return 1
  git lfs pointer --check --file="$path" >/dev/null 2>&1
}

remove_vcs_leftovers() {
  local root="$1"
  if [[ -d "$root" ]]; then
    find "$root" -name .gitattributes -delete
    find "$root" -type f -size -1025c -print0 | while IFS= read -r -d '' f; do
      if is_git_lfs_pointer "$f"; then
        rm -f "$f"
      fi
    done
    return
  fi
  if is_git_lfs_pointer "$root"; then
    rm -f "$root"
  fi
}

copy_game_folder() {
  local from="$1"
  local to="$2"
  local label="$3"
  [[ -d "$from" ]] || die "Official $label folder not found: $from"
  rm -rf "$to"
  cp -a "$from" "$to"
  remove_vcs_leftovers "$to"
  normalize_copied "$to"
  echo "Copied $label"
}

install_application_xml() {
  local from="$1/META-INF/AIR/application.xml"
  local to="$ROOT/application.xml"
  [[ -f "$from" ]] || die "Official application.xml not found: $from"
  cp -a "$from" "$to"
  remove_vcs_leftovers "$to"
  normalize_copied "$to"
  echo "Copied application.xml"
}

add_steam_native_libs() {
  local game="$1"
  local stage="$2"
  local ane_root="$stage/META-INF/ANE"
  [[ -d "$ane_root" ]] || return 0
  local platform_dir platform lib
  for platform_dir in "$ane_root"/*/; do
    [[ -d "$platform_dir" ]] || continue
    platform="$(basename "$platform_dir")"
    lib="$(steam_lib_for_platform "$platform")"
    [[ -n "$lib" && -f "$game/$lib" ]] || continue
    cp -a "$game/$lib" "$platform_dir/$lib"
    echo "Added $lib to $platform"
  done
}

ane_trees_match() {
  local a="$1"
  local b="$2"
  local fa fb rel
  fa="$(cd "$a" && find . -type f ! -name mimetype | sort)"
  fb="$(cd "$b" && find . -type f ! -name mimetype | sort)"
  [[ "$fa" == "$fb" ]] || return 1
  while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    cmp -s "$a/$rel" "$b/$rel" || return 1
  done <<< "$fa"
  return 0
}

pack_ane() {
  local stage="$1"
  local out_file="$2"
  command -v zip >/dev/null 2>&1 || die "zip is required to pack the ANE"
  printf '%s' "$MIME_TYPE" > "$stage/mimetype"
  mkdir -p "$(dirname "$out_file")"
  rm -f "$out_file"
  (
    cd "$stage"
    zip -0 -X "$out_file" mimetype
    zip -r -X "$out_file" . -x mimetype
  )
}

build_ane() {
  local game="$1"
  local ext_dir="$game/META-INF/AIR/extensions/$EXTENSION_ID"
  [[ -d "$ext_dir" ]] || die "Official ANE folder not found: $ext_dir"

  local stage
  stage="$(mktemp -d "${TMPDIR:-/tmp}/dr-ane.XXXXXX")"
  trap 'rm -rf "$stage"' RETURN
  cp -a "$ext_dir"/. "$stage"/
  add_steam_native_libs "$game" "$stage"

  if [[ -f "$ANE_OUT" ]] && command -v unzip >/dev/null 2>&1; then
    local unpacked
    unpacked="$(mktemp -d "${TMPDIR:-/tmp}/dr-ane-unpacked.XXXXXX")"
    if unzip -qq -o "$ANE_OUT" -d "$unpacked" && ane_trees_match "$unpacked" "$stage"; then
      rm -rf "$unpacked"
      echo "ANE payloads unchanged, keeping $ANE_OUT"
      return 0
    fi
    rm -rf "$unpacked"
  fi

  echo "Packing $ANE_OUT ..."
  pack_ane "$stage" "$ANE_OUT"
}

GAME="$(find_game_dir)"
FFDEC_PATH="$(find_ffdec)"
git lfs version >/dev/null 2>&1 || die "git lfs is required to detect leftover Git LFS pointer files from the official install."
SWF="$GAME/DungeonBustersProject.swf"
EXPORT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dr-as.XXXXXX")"

echo "Game:  $GAME"
echo "FFDec: $FFDEC_PATH"

cleanup() { rm -rf "$EXPORT_DIR"; }
trap cleanup EXIT

export_scripts "$FFDEC_PATH" "$SWF" "$EXPORT_DIR"
install_src "$EXPORT_DIR" "$SWF"
mkdir -p "$ROOT/data"
copy_game_folder "$GAME/Resources" "$ROOT/data/Resources" "data/Resources"
copy_game_folder "$GAME/DbConfiguration" "$ROOT/data/DbConfiguration" "data/DbConfiguration"
install_application_xml "$GAME"
build_ane "$GAME"

echo "Done."
echo "  src/, data/, and application.xml refreshed from the official game"
echo "  $ANE_OUT packed from the official native extension if payloads changed"
