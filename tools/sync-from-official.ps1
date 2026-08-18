#Requires -Version 5.1
<#
.SYNOPSIS
  Decompile the official Steam SWF into src/, copy game assets and application.xml, and rebuild FRESteamWorks.ane.

.PARAMETER GameDir
  Official Dungeon Rampage install directory. Also accepted as DUNGEON_RAMPAGE_DIR.

.PARAMETER Ffdec
  Path to ffdec.bat, ffdec-cli.exe, or ffdec.jar. Also accepted as FFDEC_HOME (install dir or file).
  Prefer the dev branch of https://github.com/Tutez64/jpexs-decompiler; upstream stable releases may lag behind.
#>
[CmdletBinding()]
param(
    [string]$GameDir = $env:DUNGEON_RAMPAGE_DIR,
    [string]$Ffdec = $env:FFDEC_HOME
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$SrcDir = Join-Path $Root "src"
$AneOut = Join-Path $Root "extensions\FRESteamWorks.ane"
$MimeType = "application/vnd.adobe.air-native-extension-package+zip"
$ExtensionId = "com.amanitadesign.steam.FRESteamWorks"

# Steam redistributables live next to the official exe. Copy them into every
# matching ANE platform directory that already exists in the official extension
# (do not create platforms the game did not ship). Same mapping on every OS.
$SteamLibToPlatform = @{
    "steam_api.dll"      = "Windows-x86"
    "steam_api64.dll"    = "Windows-x86-64"
    "libsteam_api.so"    = "Linux-x86-64"
    "libsteam_api.dylib" = "MacOS-x86-64"
}

function Convert-CopiedFiles {
    param([string]$Path)
    $textExt = @('.as', '.xml', '.json', '.txt', '.md', '.sha256')
    $utf8 = New-Object System.Text.UTF8Encoding $false
    $items = @()
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        $items = @(Get-Item -LiteralPath $Path)
    }
    elseif (Test-Path -LiteralPath $Path -PathType Container) {
        $items = @(Get-ChildItem -LiteralPath $Path -Recurse -File -Force -ErrorAction SilentlyContinue)
    }
    else {
        return
    }
    foreach ($file in $items) {
        if ($textExt -notcontains $file.Extension.ToLowerInvariant()) { continue }
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        if ($bytes -notcontains [byte]13) { continue }
        $text = $utf8.GetString($bytes)
        $converted = $text.Replace("`r`n", "`n").Replace("`r", "`n")
        [System.IO.File]::WriteAllBytes($file.FullName, $utf8.GetBytes($converted))
    }
}

function Find-GameDir {
    param([string]$Hint)
    $candidates = @()
    if ($Hint) { $candidates += $Hint }
    $candidates += @(
        "C:\Program Files (x86)\Steam\steamapps\common\DungeonRampage",
        "C:\Program Files\Steam\steamapps\common\DungeonRampage"
    )
    foreach ($dir in $candidates) {
        $swf = Join-Path $dir "DungeonBustersProject.swf"
        if (Test-Path -LiteralPath $swf) {
            return (Resolve-Path -LiteralPath $dir).Path
        }
    }
    throw "Official game not found. Install Dungeon Rampage or pass -GameDir / DUNGEON_RAMPAGE_DIR."
}

function Find-Ffdec {
    param([string]$Hint)
    $files = @()
    if ($Hint) {
        if (Test-Path -LiteralPath $Hint -PathType Leaf) {
            $files += $Hint
        }
        else {
            $files += @(
                (Join-Path $Hint "ffdec.bat"),
                (Join-Path $Hint "ffdec-cli.exe"),
                (Join-Path $Hint "ffdec.jar")
            )
        }
    }
    $cmd = Get-Command ffdec.bat, ffdec-cli.exe, ffdec -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd) { $files += $cmd.Source }
    $files += @(
        "C:\Program Files (x86)\FFDec\ffdec.bat",
        "C:\Program Files\FFDec\ffdec.bat",
        "C:\Program Files (x86)\FFDec\ffdec-cli.exe",
        "C:\Program Files\FFDec\ffdec-cli.exe"
    )
    foreach ($file in $files) {
        if ($file -and (Test-Path -LiteralPath $file -PathType Leaf)) {
            return (Resolve-Path -LiteralPath $file).Path
        }
    }
    throw "JPEXS FFDec not found. Prefer the dev branch of https://github.com/Tutez64/jpexs-decompiler (fixes for this project may not be in the latest upstream release yet). Pass -Ffdec / FFDEC_HOME."
}

function Invoke-Ffdec {
    param(
        [string]$FfdecPath,
        [string[]]$FfdecArgs
    )
    $env:FFDEC_MEMORY = "2048m"
    if ($FfdecPath -like "*.jar") {
        $java = Get-Command java -ErrorAction SilentlyContinue
        if (-not $java) { throw "java is required to run ffdec.jar" }
        & $java.Source -Xmx2048m -jar $FfdecPath @FfdecArgs
    }
    else {
        & $FfdecPath @FfdecArgs
    }
    if ($LASTEXITCODE -ne 0) {
        throw "FFDec failed with exit code $LASTEXITCODE"
    }
}

function Export-Scripts {
    param(
        [string]$FfdecPath,
        [string]$SwfPath,
        [string]$ExportDir
    )
    if (Test-Path -LiteralPath $ExportDir) {
        Remove-Item -LiteralPath $ExportDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $ExportDir | Out-Null
    Write-Host "Decompiling $SwfPath ..."
    Invoke-Ffdec -FfdecPath $FfdecPath -FfdecArgs @(
        "-config", "paramNamesEnable=true",
        "-exportembed",
        "-exportTimeout", "1800",
        "-export", "script",
        $ExportDir,
        $SwfPath
    )
}

function Get-FileSha256 {
    param([string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Install-Src {
    param(
        [string]$ExportDir,
        [string]$SwfPath
    )
    $scripts = Join-Path $ExportDir "scripts"
    if (-not (Test-Path -LiteralPath $scripts)) {
        $scripts = $ExportDir
    }
    $asFiles = Get-ChildItem -LiteralPath $scripts -Recurse -Filter *.as -ErrorAction SilentlyContinue
    if (-not $asFiles) {
        throw "FFDec produced no ActionScript files under $ExportDir"
    }

    # assets.swf is synthesized by FFDec (not a raw dump). Hash the official SWF
    # instead: if those bytes did not change, sprite tags did not change.
    $stampName = "assets.swf.source.sha256"
    $stampFile = Join-Path $Root "tools\$stampName"
    $assetsKeep = $null
    $oldStamp = ""
    $existingAssets = Join-Path $SrcDir "_assets"
    if (Test-Path -LiteralPath $existingAssets) {
        $assetsKeep = Join-Path ([System.IO.Path]::GetTempPath()) ("dr-assets-" + [guid]::NewGuid().ToString("n"))
        New-Item -ItemType Directory -Path $assetsKeep | Out-Null
        Copy-Item -LiteralPath $existingAssets -Destination (Join-Path $assetsKeep "_assets") -Recurse -Force
    }
    if (Test-Path -LiteralPath $stampFile) {
        $oldStamp = ([System.IO.File]::ReadAllText($stampFile)).Trim()
    }
    $newStamp = Get-FileSha256 -Path $SwfPath

    if (Test-Path -LiteralPath $SrcDir) {
        Remove-Item -LiteralPath $SrcDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $SrcDir | Out-Null
    Copy-Item -Path (Join-Path $scripts "*") -Destination $SrcDir -Recurse -Force

    $keepAssets = $false
    if ($assetsKeep) {
        $keptSwf = Join-Path $assetsKeep "_assets\assets.swf"
        if ((Test-Path -LiteralPath $keptSwf) -and (-not $oldStamp -or $oldStamp -eq $newStamp)) {
            $keepAssets = $true
        }
    }

    $destAssets = Join-Path $SrcDir "_assets"
    if (Test-Path -LiteralPath $destAssets) {
        Remove-Item -LiteralPath $destAssets -Recurse -Force
    }
    if ($keepAssets) {
        Copy-Item -LiteralPath (Join-Path $assetsKeep "_assets") -Destination $destAssets -Recurse -Force
        Write-Host "Keeping src/_assets (official SWF hash unchanged)"
    }
    else {
        $assetsSrc = Join-Path $ExportDir "_assets"
        if (Test-Path -LiteralPath $assetsSrc) {
            Copy-Item -LiteralPath $assetsSrc -Destination $destAssets -Recurse -Force
            Write-Host "Updating src/_assets from FFDec (official SWF changed)"
        }
        elseif ($assetsKeep) {
            Copy-Item -LiteralPath (Join-Path $assetsKeep "_assets") -Destination $destAssets -Recurse -Force
        }
    }
    if ($assetsKeep) {
        Remove-Item -LiteralPath $assetsKeep -Recurse -Force -ErrorAction SilentlyContinue
    }

    if (Test-Path -LiteralPath $destAssets) {
        $utf8 = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($stampFile, ($newStamp + "`n"), $utf8)
        Convert-CopiedFiles -Path $stampFile
    }
    Convert-CopiedFiles -Path $SrcDir
}

function Test-GitLfsPointer {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $false
    }
    if ((Get-Item -LiteralPath $Path).Length -gt 1024) {
        return $false
    }
    git lfs pointer --check --file="$Path" 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Remove-VcsLeftovers {
    param([string]$Root)
    if (Test-Path -LiteralPath $Root -PathType Container) {
        Get-ChildItem -LiteralPath $Root -Recurse -Force -Filter .gitattributes -ErrorAction SilentlyContinue |
            Remove-Item -Force
        Get-ChildItem -LiteralPath $Root -Recurse -File -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.Length -le 1024 } |
            ForEach-Object {
                if (Test-GitLfsPointer $_.FullName) {
                    Remove-Item -LiteralPath $_.FullName -Force
                }
            }
        return
    }
    if (Test-GitLfsPointer $Root) {
        Remove-Item -LiteralPath $Root -Force
    }
}

function Copy-GameFolder {
    param(
        [string]$From,
        [string]$To,
        [string]$Label
    )
    if (-not (Test-Path -LiteralPath $From)) {
        throw "Official $Label folder not found: $From"
    }
    if (Test-Path -LiteralPath $To) {
        Remove-Item -LiteralPath $To -Recurse -Force
    }
    Copy-Item -LiteralPath $From -Destination $To -Recurse -Force
    Remove-VcsLeftovers -Root $To
    Convert-CopiedFiles -Path $To
    Write-Host "Copied $Label"
}

function Install-ApplicationXml {
    param([string]$Game)
    $from = Join-Path $Game "META-INF\AIR\application.xml"
    $to = Join-Path $Root "application.xml"
    if (-not (Test-Path -LiteralPath $from)) {
        throw "Official application.xml not found: $from"
    }
    Copy-Item -LiteralPath $from -Destination $to -Force
    Remove-VcsLeftovers -Root $to
    Convert-CopiedFiles -Path $to
    Write-Host "Copied application.xml"
}

function Add-SteamNativeLibs {
    param(
        [string]$Game,
        [string]$Stage
    )
    $aneRoot = Join-Path $Stage "META-INF\ANE"
    if (-not (Test-Path -LiteralPath $aneRoot)) {
        return
    }
    Get-ChildItem -LiteralPath $aneRoot -Directory | ForEach-Object {
        $platform = $_.Name
        foreach ($lib in $SteamLibToPlatform.Keys) {
            if ($SteamLibToPlatform[$lib] -ne $platform) { continue }
            $from = Join-Path $Game $lib
            if (Test-Path -LiteralPath $from) {
                Copy-Item -LiteralPath $from -Destination (Join-Path $_.FullName $lib) -Force
                Write-Host "Added $lib to $platform"
            }
        }
    }
}

function Get-AneRelativeFiles {
    param([string]$Root)
    Get-ChildItem -LiteralPath $Root -Recurse -File -Force -ErrorAction SilentlyContinue |
        ForEach-Object {
            $_.FullName.Substring($Root.Length).TrimStart('\', '/').Replace('\', '/')
        } |
        Where-Object { $_ -ne 'mimetype' } |
        Sort-Object
}

function Test-AneTreesMatch {
    param(
        [string]$A,
        [string]$B
    )
    $fa = @(Get-AneRelativeFiles -Root $A)
    $fb = @(Get-AneRelativeFiles -Root $B)
    if (($fa -join '|') -ne ($fb -join '|')) {
        return $false
    }
    foreach ($rel in $fa) {
        $pa = Join-Path $A ($rel.Replace('/', '\'))
        $pb = Join-Path $B ($rel.Replace('/', '\'))
        if ((Get-FileSha256 -Path $pa) -ne (Get-FileSha256 -Path $pb)) {
            return $false
        }
    }
    return $true
}

function New-AneZip {
    param(
        [string]$Stage,
        [string]$OutFile
    )
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $mimeFile = Join-Path $Stage "mimetype"
    [System.IO.File]::WriteAllText($mimeFile, $MimeType)

    $outDir = Split-Path -Parent $OutFile
    if (-not (Test-Path -LiteralPath $outDir)) {
        New-Item -ItemType Directory -Path $outDir | Out-Null
    }
    if (Test-Path -LiteralPath $OutFile) {
        Remove-Item -LiteralPath $OutFile -Force
    }

    $zip = [System.IO.Compression.ZipFile]::Open($OutFile, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip, $mimeFile, "mimetype", [System.IO.Compression.CompressionLevel]::NoCompression
        ) | Out-Null
        Get-ChildItem -LiteralPath $Stage -Recurse -File | Where-Object { $_.Name -ne "mimetype" -or $_.DirectoryName -ne $Stage } | ForEach-Object {
            $rel = $_.FullName.Substring($Stage.Length + 1).Replace("\", "/")
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                $zip, $_.FullName, $rel, [System.IO.Compression.CompressionLevel]::Optimal
            ) | Out-Null
        }
    }
    finally {
        $zip.Dispose()
    }
}

function Build-Ane {
    param([string]$Game)
    $extDir = Join-Path $Game "META-INF\AIR\extensions\$ExtensionId"
    if (-not (Test-Path -LiteralPath $extDir)) {
        throw "Official ANE folder not found: $extDir"
    }

    $stage = Join-Path ([System.IO.Path]::GetTempPath()) ("dr-ane-" + [guid]::NewGuid().ToString("n"))
    New-Item -ItemType Directory -Path $stage | Out-Null
    try {
        Copy-Item -Path (Join-Path $extDir "*") -Destination $stage -Recurse -Force
        Add-SteamNativeLibs -Game $Game -Stage $stage

        $keep = $false
        if (Test-Path -LiteralPath $AneOut) {
            $unpacked = Join-Path ([System.IO.Path]::GetTempPath()) ("dr-ane-unpacked-" + [guid]::NewGuid().ToString("n"))
            try {
                Add-Type -AssemblyName System.IO.Compression.FileSystem
                [System.IO.Compression.ZipFile]::ExtractToDirectory($AneOut, $unpacked)
                $keep = Test-AneTreesMatch -A $unpacked -B $stage
            }
            catch {
                $keep = $false
            }
            finally {
                if (Test-Path -LiteralPath $unpacked) {
                    Remove-Item -LiteralPath $unpacked -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }

        if ($keep) {
            Write-Host "ANE payloads unchanged, keeping $AneOut"
        }
        else {
            Write-Host "Packing $AneOut ..."
            New-AneZip -Stage $stage -OutFile $AneOut
        }
    }
    finally {
        Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$game = Find-GameDir -Hint $GameDir
$ffdec = Find-Ffdec -Hint $Ffdec
git lfs version 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "git lfs is required to detect leftover Git LFS pointer files from the official install."
}
$swf = Join-Path $game "DungeonBustersProject.swf"
$exportDir = Join-Path ([System.IO.Path]::GetTempPath()) ("dr-as-" + [guid]::NewGuid().ToString("n"))

Write-Host "Game:  $game"
Write-Host "FFDec: $ffdec"

try {
    Export-Scripts -FfdecPath $ffdec -SwfPath $swf -ExportDir $exportDir
    Install-Src -ExportDir $exportDir -SwfPath $swf
}
finally {
    Remove-Item -LiteralPath $exportDir -Recurse -Force -ErrorAction SilentlyContinue
}

$dataDir = Join-Path $Root "data"
if (-not (Test-Path -LiteralPath $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir | Out-Null
}
Copy-GameFolder -From (Join-Path $game "Resources") -To (Join-Path $dataDir "Resources") -Label "data/Resources"
Copy-GameFolder -From (Join-Path $game "DbConfiguration") -To (Join-Path $dataDir "DbConfiguration") -Label "data/DbConfiguration"
Install-ApplicationXml -Game $game
Build-Ane -Game $game

Write-Host "Done."
Write-Host "  src/, data/, and application.xml refreshed from the official game"
Write-Host "  $AneOut packed from the official native extension if payloads changed"
