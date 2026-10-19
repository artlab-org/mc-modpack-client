# artlab MC modpack install script (Windows PowerShell)
# Usage: irm https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/install.ps1 | iex
# Or:    powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = "Stop"
$REPO_URL = "https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main"
$MODS_DIR = "$env:APPDATA\.minecraft\mods"

Write-Host ""
Write-Host "=== artlab MC modpack installer ===" -ForegroundColor Cyan
Write-Host "Mods target dir: $MODS_DIR"
Write-Host ""

# Verify Minecraft is installed
if (-not (Test-Path $env:APPDATA\.minecraft)) {
    Write-Host "Error: .minecraft not found at $env:APPDATA\.minecraft" -ForegroundColor Red
    Write-Host "Lance une fois Minecraft 26.3 dans ton launcher officiel pour creer le dossier."
    exit 1
}

# Verify Java
$java = (Get-Command java -ErrorAction SilentlyContinue)
if (-not $java) {
    Write-Host "Error: java not in PATH" -ForegroundColor Red
    Write-Host "Installe Java 21+ depuis https://adoptium.net/"
    exit 1
}
$javaVer = (& java -version 2>&1 | Select-String "version" | ForEach-Object { $_.Line })
Write-Host "Java detecte: $javaVer"

# Create mods dir
if (-not (Test-Path $MODS_DIR)) {
    New-Item -ItemType Directory -Path $MODS_DIR -Force | Out-Null
}

# Helper to compute SHA512
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

# Mods list: slug, version filter (auto-resolved via Modrinth API)
$mods = @(
    "fabric-api",
    "sodium",
    "iris",
    "lithium",
    "ferrite-core",
    "krypton",
    "modmenu",
    "cloth-config",
    "distanthorizons",
    "fabric-language-kotlin",
    "viafabric",
    "chunky"
)

Write-Host "Telechargement de $($mods.Count) mods depuis Modrinth..." -ForegroundColor Yellow

foreach ($slug in $mods) {
    Write-Host ""
    Write-Host "[$slug]" -ForegroundColor Cyan
    $apiUrl = "https://api.modrinth.com/v2/project/$slug/version?game_versions=%5B%2226.3%22%5D&loaders=%5B%22fabric%22%5D"

    try {
        $versions = Invoke-RestMethod -Uri $apiUrl -TimeoutSec 30
    } catch {
        Write-Host "  ERREUR API Modrinth pour $slug : $_" -ForegroundColor Red
        continue
    }

    if (-not $versions -or $versions.Count -eq 0) {
        Write-Host "  Pas de version MC 26.3 Fabric pour $slug, skip" -ForegroundColor Yellow
        continue
    }

    $version = $versions[0]
    $file = $version.files[0]
    $dest = Join-Path $MODS_DIR $file.filename
    $expectedSha = $file.hashes.sha512

    if (Test-Path $dest) {
        $existingSha = Get-SHA512 $dest
        if ($existingSha -eq $expectedSha) {
            Write-Host "  Deja installe: $($file.filename) ($($version.version_number))" -ForegroundColor Green
            continue
        }
    }

    Write-Host "  DL $($file.filename) ($([math]::Round($file.size/1KB)) KB)..."
    try {
        Invoke-WebRequest -Uri $file.url -OutFile $dest -TimeoutSec 120 -UseBasicParsing
    } catch {
        Write-Host "  ERREUR telechargement : $_" -ForegroundColor Red
        continue
    }

    $actualSha = Get-SHA512 $dest
    if ($actualSha -eq $expectedSha) {
        Write-Host "  OK $($version.version_number)" -ForegroundColor Green
    } else {
        Write-Host "  SHA mismatch, fichier supprime" -ForegroundColor Red
        Remove-Item $dest -Force
    }
}

Write-Host ""
Write-Host "=== Installation terminee ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "PROCHAINES ETAPES :" -ForegroundColor Yellow
Write-Host "1. Ouvre ton launcher (officiel, MultiMC, TLauncher, SKLauncher)"
Write-Host "2. Selectionne le profil Fabric Loader 0.19.5"
Write-Host "3. Lance Minecraft 26.3"
Write-Host "4. Verifie que 'Mod Menu' apparait dans le menu principal"
Write-Host "5. Ajoute le serveur : lx-gaming port 25565"
Write-Host "6. Tape /register <password> puis /login <password> en jeu"
Write-Host ""
Write-Host "Si probleme : ouvre une issue sur https://github.com/artlab-org/mc-modpack-client/issues"
