# Dungeon Rampage Decompiled

ActionScript / AIR sources for [Dungeon Rampage](https://store.steampowered.com/app/3053950/Dungeon_Rampage/), decompiled from the Steam SWF.

This project is only used to make sure the decompiled code is faithful before porting it to Haxe. \
See [Dungeon Rampage Haxe](https://github.com/Tutez64/Dungeon-Rampage-Haxe).

## Layout

| Path              | Role                                                 |
|-------------------|------------------------------------------------------|
| `src/`            | Decompiled ActionScript                              |
| `data/`           | Game resources (`Resources/` and `DbConfiguration/`) |
| `extensions/`     | Steam ANE (`FRESteamWorks.ane`)                      |
| `tools/`          | Synchronisation scripts                              |
| `application.xml` | AIR descriptor                                       |

## Requirements

- [HARMAN AIR SDK](https://airsdk.harman.com/download)
- [IntelliJ IDEA](https://www.jetbrains.com/idea/) with the **Flash/Flex** plugin
- The official Steam game
- Steam running while you play

Windows and macOS can use the free-tier SDK and ADL. [HARMAN's Linux AIR runtime and ADL require a commercial license](https://airsdk.harman.com/faq).

## One-time AIR SDK setup

The Flex plugin launches `adl` from the SDK `bin` folder, with no working-directory setting. Steam looks for `steam_appid.txt` next to that executable (the process working directory is often the SDK `bin` folder).

Copy `steam_appid.txt` from this repo into that `bin` folder.

On **Windows**, there is also no ADL / IntelliJ option to pick a 64-bit launcher. `<architecture>64</architecture>` in `application.xml` applies to packaged builds, not to ADL. HARMAN ships a 32-bit `adl.exe` and a 64-bit `adl64.exe`; the Steam ANE is 64-bit, so replace `adl.exe` with a copy of `adl64.exe`. macOS ships a 64-bit `adl` already.

`steam_api64.dll` (and the other Steam libs) are already inside `extensions/FRESteamWorks.ane`. You do not need to copy them into the SDK or `System32`.

In IntelliJ, open **File > Project Structure**. Under **SDKs**, add the AIR SDK you installed, then select it as the SDK for this module (the Flex build configuration's **Dependencies**).

## Refresh from the official game

Use the **`dev`** branch of [my JPEXS FFDec fork](https://github.com/Tutez64/jpexs-decompiler/tree/dev), not the latest upstream stable release. Fixes for this project land there first and are not always merged (or released) upstream yet. The Linux script also needs `zip` and `unzip` (usually already installed).

```powershell
powershell -File tools/sync-from-official.ps1
```

```bash
./tools/sync-from-official.sh
```

This **replaces** `src/`, `data/Resources/`, `data/DbConfiguration/`, and `application.xml`. It decompiles `DungeonBustersProject.swf` with `paramNamesEnable=true`, copies assets and the AIR descriptor from the game install, and rebuilds `extensions/FRESteamWorks.ane` only if the unpacked payloads differ from the official native extension (every platform directory the game ships, plus the matching Steam API library next to each native binary). `src/_assets/assets.swf` is kept unless the official SWF hash changed (FFDec reserializes that file, so the hash of `DungeonBustersProject.swf` is the stable check). Leftover Git metadata from the official install (`.gitattributes` and [Git LFS](https://git-lfs.com) pointer files) is dropped.

`data/` is a Flex source folder (not ActionScript). On compile, IntelliJ copies those files next to the SWF as `out/Resources/` and `out/DbConfiguration/`.

Optional: `-GameDir` / `--game` / `DUNGEON_RAMPAGE_DIR`, and `-Ffdec` / `--ffdec` / `FFDEC_HOME`.

### After a fresh decompile

GreenSock's `TimelineLite.goto` must be renamed (current upstream calls it `seek`) or the AIR compiler will reject it.

## Build & run

Open the project in IntelliJ and run the **DungeonRampageDecompiled** Flash configuration.

That ADL loop is the full check (your descriptor, your ANE, the SDK runtime). On Linux it needs the commercial HARMAN license.

A coarser check is to copy `out/DungeonBustersProject.swf` over the official `DungeonBustersProject.swf` in the Steam install and launch the game from Steam as usual. On Linux, Proton can run that Windows install. It is enough to see whether the recompiled SWF actually plays.

### Debugging

Compiler options and ADL options are independent:

- **Additional compiler options** (`-debug=true -omit-trace-statements=false`) are baked into the SWF: debug info and `trace()` calls. They do not start a debug session.
- **AIR Debug Launcher options** (`-nodebug`) tell ADL not to wait for a debugger. **Run** starts immediately. IntelliJ **Debug** will not attach while this flag is present.

To actually debug, remove `-nodebug` from the run configuration, then use **Debug**. Keep the compiler `-debug=true` either way if you want traces or the option to attach later.

## Disclaimer

Dungeon Rampage Decompiled is an unofficial, fan-made project and is not affiliated with, endorsed by, sponsored by, or authorized by the developers, publishers, or other rights holders of Dungeon Rampage.

Dungeon Rampage and all original game code, assets, artwork, audio, characters, trademarks, and other intellectual property belong to their respective rights holders. This repository does not grant any rights to that material, and it does not include a license for it.
