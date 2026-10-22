# artlab MC modpack install script (Windows PowerShell)
# Usage:
#   irm https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/install.ps1 | iex
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Launcher auto -Clean
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Launcher sklauncher -Version 26.3
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Launcher multimc -Instance "artlab"
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Launcher official

# Default params (overridable via CLI flags)
param(
    [ValidateSet("auto","official","sklauncher","multimc","prism","custom")]
    [string]$Launcher = "auto",
    [string]$Version = "26.3",
    [switch]$Clean = $false,
    [string]$Dir = "",
    [string]$Instance = ""
)
$ErrorActionPreference = "Stop"
$REPO_URL = "https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main"

Write-Host ""
Write-Host "=== artlab MC modpack installer ===" -ForegroundColor Cyan
Write-Host "Launcher: $Launcher | MC version: $Version | Clean: $Clean"
Write-Host ""

# ====== Detect launcher and find mods directory ======

function Find-ModsDir {
    param([string]$Launcher, [string]$Version, [string]$CustomDir, [string]$Instance)

    # If user provides a custom dir, use it
    if ($CustomDir) {
        if (Test-Path $CustomDir) {
            return $CustomDir
        }
        Write-Host "Custom dir not found: $CustomDir" -ForegroundColor Red
        exit 1
    }

    $appdata = $env:APPDATA

    switch ($Launcher) {

        "official" {
            # Mojang official launcher
            $dir = Join-Path $appdata ".minecraft\mods"
            return $dir
        }

        "sklauncher" {
            # SKLauncher stores versions in versions\<version>\.fabric\mods\ or versions\<version>\mods\
            # The MC version subfolder may have multiple profiles (vanilla/fabric)
            $versionsDir = Join-Path $appdata ".minecraft\versions"
            if (-not (Test-Path $versionsDir)) {
                Write-Host "SKLauncher .minecraft\versions not found" -ForegroundColor Red
                exit 1
            }

            # Find the fabric version folder for our MC version
            # SKLauncher names them like "Fabric-Loader-0.19.5-26.3" or just "26.3-fabric"
            $candidates = Get-ChildItem -Path $versionsDir -Directory | Where-Object {
                $_.Name -like "*${Version}*" -or $_.Name -like "*${Version}*fabric*" -or $_.Name -like "*fabric*${Version}*"
            }
            if ($candidates.Count -eq 0) {
                Write-Host "No Fabric profile for MC $Version found in $versionsDir" -ForegroundColor Red
                Write-Host "Available versions:"
                Get-ChildItem -Path $versionsDir -Directory | ForEach-Object { Write-Host "  $($_.Name)" }
                Write-Host ""
                Write-Host "Create a Fabric Loader profile for MC $Version in SKLauncher, then re-run this script." -ForegroundColor Yellow
                exit 1
            }

            if ($candidates.Count -gt 1) {
                Write-Host "Multiple Fabric profiles found for MC $Version :" -ForegroundColor Yellow
                $candidates | ForEach-Object { Write-Host "  $($_.Name)" }
                Write-Host "Using the first one: $($candidates[0].Name)" -ForegroundColor Yellow
            }

            $profileDir = $candidates[0].FullName
            # SKLauncher puts mods in <profileDir>\mods\ OR <profileDir>\.fabric\mods\
            foreach ($sub in @("mods", ".fabric\mods")) {
                $test = Join-Path $profileDir $sub
                if (Test-Path (Split-Path $test -Parent)) {
                    # We create it if doesn't exist
                    New-Item -ItemType Directory -Path $test -Force | Out-Null
                    return $test
                }
            }
            # Fallback: mods/ at the root of the version dir
            return (Join-Path $profileDir "mods")
        }

        "multimc" {
            # MultiMC/Prism : instances\<name>\.minecraft\mods\
            if (-not $Instance) {
                Write-Host "MultiMC requires -Instance <name> parameter" -ForegroundColor Red
                exit 1
            }
            $instanceDir = Join-Path (Join-Path $appdata "..\..\..\MultiMC\instances") $Instance
            # Resolve ../ relative paths
            $instanceDir = [System.IO.Path]::GetFullPath($instanceDir)
            $dir = Join-Path $instanceDir ".minecraft\mods"
            if (-not (Test-Path $instanceDir)) {
                Write-Host "MultiMC instance not found: $instanceDir" -ForegroundColor Red
                exit 1
            }
            return $dir
        }

        "prism" {
            # Prism Launcher : PrismLauncher\instances\<name>\.minecraft\mods\
            $instancesRoot = Join-Path $appdata "..\..\..\PrismLauncher\instances"
            $instancesRoot = [System.IO.Path]::GetFullPath($instancesRoot)
            if (-not $Instance) {
                Write-Host "Prism requires -Instance <name> parameter" -ForegroundColor Red
                exit 1
            }
            $dir = Join-Path (Join-Path $instancesRoot $Instance) ".minecraft\mods"
            if (-not (Test-Path (Split-Path $dir -Parent))) {
                Write-Host "Prism instance not found: $dir" -ForegroundColor Red
                exit 1
            }
            return $dir
        }

        "custom" {
            if (-not $CustomDir) {
                Write-Host "Custom mode requires -Dir <path>" -ForegroundColor Red
                exit 1
            }
            if (-not (Test-Path $CustomDir)) {
                New-Item -ItemType Directory -Path $CustomDir -Force | Out-Null
            }
            return $CustomDir
        }

        "auto" {
            # Auto-detect based on existing files
            $official = Join-Path $appdata ".minecraft\mods"
            $versionsDir = Join-Path $appdata ".minecraft\versions"

            # Check if SKLauncher is installed (look for its exe)
            $skExe = Get-ChildItem -Path $appdata -Filter "SKLauncher*" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($skExe) {
                Write-Host "SKLauncher detected — using SKLauncher profile" -ForegroundColor Cyan
                return (Find-ModsDir -Launcher "sklauncher" -Version $Version -CustomDir "" -Instance "")
            }

            # Check MultiMC / Prism dirs
            $multimcRoot = Join-Path $appdata "..\..\..\MultiMC\instances"
            $multimcRoot = [System.IO.Path]::GetFullPath($multimcRoot)
            $prismRoot = Join-Path $appdata "..\..\..\PrismLauncher\instances"
            $prismRoot = [System.IO.Path]::GetFullPath($prismRoot)
            if (Test-Path $prismRoot) {
                Write-Host "Prism Launcher detected — using Prism instance default" -ForegroundColor Cyan
                $instances = Get-ChildItem -Path $prismRoot -Directory
                if ($instances.Count -gt 0) {
                    if (-not $Instance) { $Instance = $instances[0].Name }
                    Write-Host "Using instance: $Instance (use -Instance to override)" -ForegroundColor Yellow
                    return (Find-ModsDir -Launcher "prism" -Version $Version -CustomDir "" -Instance $Instance)
                }
            }
            if (Test-Path $multimcRoot) {
                Write-Host "MultiMC detected — using instance default" -ForegroundColor Cyan
                $instances = Get-ChildItem -Path $multimcRoot -Directory
                if ($instances.Count -gt 0) {
                    if (-not $Instance) { $Instance = $instances[0].Name }
                    Write-Host "Using instance: $Instance (use -Instance to override)" -ForegroundColor Yellow
                    return (Find-ModsDir -Launcher "multimc" -Version $Version -CustomDir "" -Instance $Instance)
                }
            }

            # Fallback : .minecraft\mods\
            Write-Host "No launcher detected — falling back to .minecraft\mods" -ForegroundColor Yellow
            return $official
        }

        default {
            Write-Host "Unknown launcher: $Launcher" -ForegroundColor Red
            exit 1
        }
    }
}

$MODS_DIR = Find-ModsDir -Launcher $Launcher -Version $Version -CustomDir $Dir -Instance $Instance
Write-Host "Mods target dir: $MODS_DIR"
Write-Host ""

# ====== Verify Minecraft is installed ======
$mcRoot = (Split-Path (Split-Path $MODS_DIR -Parent) -Parent)
if ($Launcher -eq "sklauncher") {
    $mcRoot = (Split-Path (Split-Path (Split-Path $MODS_DIR -Parent) -Parent) -Parent)
}
if (-not (Test-Path $mcRoot)) {
    Write-Host "Minecraft root not found at $mcRoot" -ForegroundColor Red
    Write-Host "Lance une fois ton launcher avec MC $Version pour creer le dossier." -ForegroundColor Yellow
    exit 1
}

# ====== Verify Java ======
$java = (Get-Command java -ErrorAction SilentlyContinue)
if (-not $java) {
    Write-Host "Error: java not in PATH" -ForegroundColor Red
    Write-Host "Installe Java 21+ : https://adoptium.net/" -ForegroundColor Red
    exit 1
}
$javaVer = (& java -version 2>&1 | Select-String "version" | ForEach-Object { $_.Line })
Write-Host "Java detecte: $javaVer"

# ====== Clean existing mods (if --Clean) ======
if ($Clean) {
    Write-Host ""
    Write-Host "=== Cleaning existing mods ===" -ForegroundColor Yellow
    $existing = Get-ChildItem -Path $MODS_DIR -Filter "*.jar" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "Removing $($existing.Count) existing mod .jar:"
        $existing | ForEach-Object {
            Write-Host "  rm $($_.Name)"
            Remove-Item $_.FullName -Force
        }
    } else {
        Write-Host "No existing mods to clean"
    }
}

# Create mods dir if missing
if (-not (Test-Path $MODS_DIR)) {
    New-Item -ItemType Directory -Path $MODS_DIR -Force | Out-Null
}

# ====== Helper: SHA512 ======
function Get-SHA512($path) {
    $hash = [System.Security.Cryptography.SHA512]::Create()
    $stream = [System.IO.File]::OpenRead($path)
    try {
        $bytes = $hash.ComputeHash($stream)
        -join ($bytes | ForEach-Object { $_.ToString("x2") })
    } finally {
        $stream.Close()
    }
}

# ====== Download from Modrinth ======
$MODS = @(
    "fabric-api"
    "sodium"
    "iris"
    "lithium"
    "ferrite-core"
    "krypton"
    "modmenu"
    "cloth-config"
    "distanthorizons"
    "fabric-language-kotlin"
    "viafabric"
    "chunky"
)

Write-Host ""
Write-Host "Telechargement de $($MODS.Count) mods depuis Modrinth (MC $Version + Fabric)..." -ForegroundColor Yellow

$ok = 0
$skipped = 0
$failed = 0

foreach ($slug in $MODS) {
    Write-Host ""
    Write-Host "[$slug]" -ForegroundColor Cyan
    $apiUrl = "https://api.modrinth.com/v2/project/$slug/version?loaders=%5B%22fabric%22%5D&game_versions=%5B%22$Version%22%5D"

    try {
        $versions = Invoke-RestMethod -Uri $apiUrl -TimeoutSec 30
    } catch {
        Write-Host "  ERREUR API Modrinth pour $slug : $_" -ForegroundColor Red
        $failed++
        continue
    }

    if (-not $versions -or $versions.Count -eq 0) {
        Write-Host "  Pas de version MC $Version Fabric pour $slug, skip" -ForegroundColor Yellow
        $skipped++
        continue
    }

    $version = $versions[0]
    $file = $version.files[0]
    $dest = Join-Path $MODS_DIR $file.filename
    $expectedSha = $file.hashes.sha512

    # Skip if already correct
    if ((Test-Path $dest) -and ((Get-SHA512 $dest) -eq $expectedSha)) {
        Write-Host "  Deja installe: $($file.filename) ($($version.version_number))" -ForegroundColor Green
        $ok++
        continue
    }

    Write-Host "  DL $($file.filename) ($([math]::Round($file.size/1KB)) KB) [$($version.version_number)]..."
    try {
        Invoke-WebRequest -Uri $file.url -OutFile $dest -TimeoutSec 120 -UseBasicParsing
    } catch {
        Write-Host "  ERREUR telechargement : $_" -ForegroundColor Red
        $failed++
        continue
    }

    $actualSha = Get-SHA512 $dest
    if ($actualSha -eq $expectedSha) {
        Write-Host "  OK" -ForegroundColor Green
        $ok++
    } else {
        Write-Host "  SHA mismatch, fichier supprime" -ForegroundColor Red
        Remove-Item $dest -Force
        $failed++
    }
}

Write-Host ""
Write-Host "=== Bilan ===" -ForegroundColor Cyan
Write-Host "OK : $ok | Skip : $skipped | Failed : $failed"
Write-Host ""

if ($failed -eq 0) {
    Write-Host "=== Installation OK ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "PROCHAINES ETAPES :" -ForegroundColor Yellow
    if ($Launcher -eq "sklauncher") {
        Write-Host "1. Ouvre SKLauncher"
        Write-Host "2. Selectionne le profil Fabric-Loader-0.19.5-26.3"
        Write-Host "3. Verifie la version MC : clic droit sur le profil > Settings > Minecraft Version doit etre 26.3 (PAS 26.1, 26.1.2, ou 26.4)"
        Write-Host "4. Lance le jeu"
    } elseif ($Launcher -in "multimc","prism") {
        Write-Host "1. Ouvre MultiMC/Prism"
        Write-Host "2. Verifie la version MC de l'instance (clic droit > Edit Instance > Settings > Minecraft Version = 26.3)"
        Write-Host "3. Lance le jeu"
    } else {
        Write-Host "1. Ouvre ton launcher"
        Write-Host "2. Force la version MC a 26.3 (PAS 26.1/26.1.2, PAS 26.4+)"
        Write-Host "3. Lance le jeu"
    }
    Write-Host "5. Verifie que 'Mod Menu' apparait dans le menu principal"
    Write-Host "6. Ajoute le serveur : mc.alabalec.net port 25565 (ou lx-gaming:25565 via tailnet)"
    Write-Host "7. Tape /register <password> puis /login <password> en jeu"
    Write-Host ""
    Write-Host "Si probleme : ouvre une issue sur https://github.com/artlab-org/mc-modpack-client/issues"
} else {
    Write-Host "=== Installation partielle ===" -ForegroundColor Yellow
    Write-Host "$failed mods ont echoue. Re-lance le script pour retry."
}
