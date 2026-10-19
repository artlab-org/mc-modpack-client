# artlab MC modpack uninstall (Windows PowerShell)
# Usage:
#   irm https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/uninstall.ps1 | iex
#   powershell -ExecutionPolicy Bypass -File uninstall.ps1 -Launcher sklauncher
#   powershell -ExecutionPolicy Bypass -File uninstall.ps1 -Launcher multimc -Instance artlab

$ErrorActionPreference = "Stop"

param(
    [ValidateSet("auto","official","sklauncher","multimc","prism","custom")]
    [string]$Launcher = "auto",
    [string]$Dir = "",
    [string]$Instance = ""
)

Write-Host "=== artlab MC modpack uninstall ===" -ForegroundColor Cyan
Write-Host "Launcher: $Launcher | Dir: $Dir"

$appdata = $env:APPDATA

# Find mods dir (same logic as install.ps1)
$MODS_DIR = ""

switch ($Launcher) {
    "sklauncher" {
        $versionsDir = Join-Path $appdata ".minecraft\versions"
        if (-not (Test-Path $versionsDir)) {
            Write-Host "SKLauncher not found" -ForegroundColor Red
            exit 1
        }
        $candidates = Get-ChildItem -Path $versionsDir -Directory | Where-Object {
            $_.Name -like "*26.3*fabric*" -or $_.Name -like "*fabric*26.3*"
        }
        if ($candidates) {
            $MODS_DIR = Join-Path $candidates[0].FullName "mods"
        }
    }
    "multimc" {
        $instancesRoot = [System.IO.Path]::GetFullPath((Join-Path $appdata "..\..\..\MultiMC\instances"))
        if (-not $Instance) { Write-Host "multimc requires -Instance" -ForegroundColor Red; exit 1 }
        $MODS_DIR = Join-Path (Join-Path $instancesRoot $Instance) ".minecraft\mods"
    }
    "prism" {
        $instancesRoot = [System.IO.Path]::GetFullPath((Join-Path $appdata "..\..\..\PrismLauncher\instances"))
        if (-not $Instance) { Write-Host "prism requires -Instance" -ForegroundColor Red; exit 1 }
        $MODS_DIR = Join-Path (Join-Path $instancesRoot $Instance) ".minecraft\mods"
    }
    "official" {
        $MODS_DIR = Join-Path $appdata ".minecraft\mods"
    }
    "custom" {
        $MODS_DIR = $Dir
    }
    default {
        $MODS_DIR = Join-Path $appdata ".minecraft\mods"
    }
}

if (-not $MODS_DIR -or -not (Test-Path $MODS_DIR)) {
    Write-Host "Mods dir not found: $MODS_DIR" -ForegroundColor Red
    exit 1
}

Write-Host "Mods dir: $MODS_DIR"
Write-Host ""

$SLUGS = @("fabric-api","sodium","iris","lithium","ferrite-core","krypton","modmenu","cloth-config","distanthorizons","fabric-language-kotlin","viafabric","chunky")

$count = 0
foreach ($slug in $SLUGS) {
    $files = Get-ChildItem -Path $MODS_DIR -Filter "*$slug*" -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        Write-Host "  rm $($f.Name)"
        Remove-Item $f.FullName -Force
        $count++
    }
}

Write-Host ""
Write-Host "$count fichiers supprimes."
Write-Host "Redemarre ton launcher."
