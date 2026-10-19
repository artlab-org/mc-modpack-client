#!/usr/bin/env bash
# artlab MC modpack install script (Linux/macOS)
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/install.sh | bash
#   curl -fsSL ... | bash -s -- --launcher auto --clean
#   curl -fsSL ... | bash -s -- --launcher sklauncher --version 26.3
#   curl -fsSL ... | bash -s -- --launcher multimc --instance artlab
#   curl -fsSL ... | bash -s -- --dir /path/to/.minecraft
#
# Launchers supported: auto | official | sklauncher | multimc | prism | custom

set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main"
MC_VERSION="${MC_VERSION:-26.3}"
LAUNCHER="auto"
CLEAN=0
DIR_OVERRIDE=""
INSTANCE=""
PRISM_LAUNCHER_BIN_DIR="${MC_PRISM_BIN:-}"
SKLAUNCHER_BIN_DIR="${MC_SKLAUNCHER_BIN:-}"

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --launcher) LAUNCHER="$2"; shift 2 ;;
        --version) MC_VERSION="$2"; shift 2 ;;
        --clean) CLEAN=1; shift ;;
        --dir) DIR_OVERRIDE="$2"; shift 2 ;;
        --instance) INSTANCE="$2"; shift 2 ;;
        --prism-bin) PRISM_LAUNCHER_BIN_DIR="$2"; shift 2 ;;
        --sklauncher-bin) SKLAUNCHER_BIN_DIR="$2"; shift 2 ;;
        -h|--help)
            sed -n '2,16p' "$0"
            exit 0 ;;
        *) echo "Unknown arg: $1" >&2; exit 1 ;;
    esac
done

echo ""
echo "=== artlab MC modpack installer ==="
echo "Launcher: $LAUNCHER | MC version: $MC_VERSION | Clean: $CLEAN"
echo ""

# ====== Launcher detection ======

detect_sklauncher() {
    # SKLauncher (Windows) — WSL detection: look for SKLauncher.exe in mounted Windows drives
    # On Linux/macOS, SKLauncher is unlikely, but check WSL just in case
    if [[ -n "$SKLAUNCHER_BIN_DIR" && -d "$SKLAUNCHER_BIN_DIR" ]]; then
        echo "$SKLAUNCHER_BIN_DIR"
        return 0
    fi
    # Try common paths
    local candidates=(
        "/mnt/c/Users/$USER/AppData/Roaming/.minecraft/versions"
        "$HOME/.minecraft/versions"
    )
    for c in "${candidates[@]}"; do
        if [[ -d "$c" ]]; then
            # Check if SKLauncher is the source — heuristic: presence of SKLauncher-specific dirs
            echo "$c"
            return 0
        fi
    done
    return 1
}

detect_prism_or_multimc() {
    # MultiMC / Prism : look for instances dir
    local candidates=(
        "$HOME/.local/share/PrismLauncher/instances"
        "$HOME/.local/share/multimc/instances"
        "$HOME/.multimc/instances"
        "$HOME/.prismlauncher/instances"
    )
    for c in "${candidates[@]}"; do
        if [[ -d "$c" ]]; then
            echo "$c"
            return 0
        fi
    done
    return 1
}

find_mods_dir() {
    # Custom override
    if [[ -n "$DIR_OVERRIDE" ]]; then
        mkdir -p "$DIR_OVERRIDE"
        echo "$DIR_OVERRIDE"
        return 0
    fi

    case "$LAUNCHER" in
        official)
            mkdir -p "$HOME/.minecraft/mods"
            echo "$HOME/.minecraft/mods"
            return 0
            ;;
        sklauncher)
            local versions_dir
            if ! versions_dir=$(detect_sklauncher); then
                echo "SKLauncher .minecraft/versions not found" >&2
                echo "Set --sklauncher-bin or run on Windows" >&2
                exit 1
            fi

            # Find a profile directory matching MC version + Fabric/loader
            local match=""
            match=$(python3 -c "
import os, glob
v='$versions_dir'; mv='$MC_VERSION'
for d in glob.glob(os.path.join(v,'*')):
    if not os.path.isdir(d): continue
    n=os.path.basename(d)
    if mv in n and any(x in n.lower() for x in ['fabric','loader']):
        print(d); break
" 2>/dev/null)

            if [[ -z "$match" ]]; then
                echo "No Fabric profile for MC $MC_VERSION in $versions_dir" >&2
                echo "Available:"
                find "$versions_dir" -mindepth 1 -maxdepth 1 -type d -printf "  %f\n" 2>/dev/null
                exit 1
            fi

            local mods="$match/mods"
            mkdir -p "$mods"
            echo "$mods"
            return 0
            ;;
        multimc)
            local root
            if ! root=$(detect_prism_or_multimc); then
                echo "MultiMC root not found" >&2; exit 1
            fi
            [[ -z "$INSTANCE" ]] && { echo "multimc needs --instance <name>" >&2; exit 1; }
            local d="$root/$INSTANCE/.minecraft/mods"
            [[ ! -d "$root/$INSTANCE" ]] && { echo "MultiMC instance not found: $root/$INSTANCE" >&2; exit 1; }
            mkdir -p "$d"
            echo "$d"
            return 0
            ;;
        prism)
            local root
            if ! root=$(detect_prism_or_multimc); then
                echo "Prism root not found" >&2; exit 1
            fi
            [[ -z "$INSTANCE" ]] && { echo "prism needs --instance <name>" >&2; exit 1; }
            local d="$root/$INSTANCE/.minecraft/mods"
            [[ ! -d "$root/$INSTANCE" ]] && { echo "Prism instance not found: $root/$INSTANCE" >&2; exit 1; }
            mkdir -p "$d"
            echo "$d"
            return 0
            ;;
        custom)
            [[ -z "$DIR_OVERRIDE" ]] && { echo "custom needs --dir <path>" >&2; exit 1; }
            mkdir -p "$DIR_OVERRIDE"
            echo "$DIR_OVERRIDE"
            return 0
            ;;
        auto)
            # Linux/macOS : SKLauncher irrelevant unless WSL. Try Prism → MultiMC → official
            if detect_prism_or_multimc >/dev/null 2>&1; then
                local root
                root=$(detect_prism_or_multimc)
                local instances=()
                while IFS= read -r d; do instances+=("$d"); done < <(find "$root" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
                if [[ ${#instances[@]} -gt 0 ]]; then
                    if [[ -z "$INSTANCE" ]]; then
                        INSTANCE=$(basename "${instances[0]}")
                        echo "[auto] Using Prism/MultiMC instance: $INSTANCE (use --instance to override)"
                    fi
                    # Detect prism vs multimc by path
                    if [[ "$root" == *Prism* ]] || [[ "$root" == *prism* ]]; then
                        local d="$root/$INSTANCE/.minecraft/mods"
                        mkdir -p "$d"
                        echo "$d"
                        return 0
                    else
                        local d="$root/$INSTANCE/.minecraft/mods"
                        mkdir -p "$d"
                        echo "$d"
                        return 0
                    fi
                fi
            fi
            # Fallback : .minecraft/mods
            mkdir -p "$HOME/.minecraft/mods"
            echo "$HOME/.minecraft/mods"
            return 0
            ;;
        *)
            echo "Unknown launcher: $LAUNCHER" >&2
            exit 1
            ;;
    esac
}

MODS_DIR=$(find_mods_dir)
echo "Mods target dir: $MODS_DIR"
echo ""

# ====== Verify Java ======
if ! command -v java >/dev/null 2>&1; then
    echo "Error: java not in PATH" >&2
    echo "Installe Java 21+ : https://adoptium.net/" >&2
    exit 1
fi
java -version 2>&1 | head -1 | sed "s/^/Java detecte: /"

# ====== Clean if requested ======
if [[ "$CLEAN" = "1" ]]; then
    echo ""
    echo "=== Cleaning existing mods ==="
    if compgen -G "$MODS_DIR/*.jar" >/dev/null; then
        local_count=$(find "$MODS_DIR" -maxdepth 1 -name "*.jar" | wc -l)
        echo "Removing $local_count existing mod .jar:"
        find "$MODS_DIR" -maxdepth 1 -name "*.jar" -exec rm -f {} \;
        find "$MODS_DIR" -maxdepth 1 -name "*.jar.disabled" -exec rm -f {} \;
    else
        echo "No existing mods"
    fi
fi

mkdir -p "$MODS_DIR"

# ====== Download from Modrinth ======
MODS=(
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

echo ""
echo "Telechargement de ${#MODS[@]} mods depuis Modrinth (MC $MC_VERSION + Fabric)..."

ok=0
skipped=0
failed=0

for slug in "${MODS[@]}"; do
    echo ""
    echo "[$slug]"

    api_url="https://api.modrinth.com/v2/project/$slug/version?loaders=%5B%22fabric%22%5D&game_versions=%5B%22$MC_VERSION%22%5D"

    api_json=$(curl -fsS "$api_url" 2>&1) || {
        echo "  ERREUR API Modrinth pour $slug" >&2
        failed=$((failed+1))
        continue
    }

    # Get first version's first file URL + SHA512 + version + filename
    file_url=$(echo "$api_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['files'][0]['url'])" 2>/dev/null) || {
        echo "  Pas de version MC $MC_VERSION Fabric pour $slug"
        skipped=$((skipped+1))
        continue
    }
    file_name=$(echo "$api_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['files'][0]['filename'])")
    expected_sha=$(echo "$api_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['files'][0]['hashes']['sha512'])")
    version=$(echo "$api_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['version_number'])")

    dest="${MODS_DIR}/${file_name}"
    if [[ -f "$dest" ]]; then
        actual=$(sha512sum "$dest" | cut -d" " -f1)
        if [[ "$actual" == "$expected_sha" ]]; then
            echo "  Deja installe: $file_name ($version)"
            ok=$((ok+1))
            continue
        fi
    fi

    echo "  DL $file_name ($version)..."
    tmp=$(mktemp)
    if ! curl -fsSL -o "$tmp" "$file_url"; then
        echo "  ERREUR telechargement" >&2
        rm -f "$tmp"
        failed=$((failed+1))
        continue
    fi
    actual=$(sha512sum "$tmp" | cut -d" " -f1)
    if [[ "$actual" == "$expected_sha" ]]; then
        mv "$tmp" "$dest"
        echo "  OK"
        ok=$((ok+1))
    else
        echo "  SHA mismatch, skip" >&2
        rm -f "$tmp"
        failed=$((failed+1))
    fi
done

echo ""
echo "=== Bilan ==="
echo "OK : $ok | Skip : $skipped | Failed : $failed"
echo ""

if [[ "$failed" = "0" ]]; then
    echo "=== Installation OK ==="
    echo ""
    echo "PROCHAINES ETAPES :"
    if [[ "$LAUNCHER" == "sklauncher" ]]; then
        echo "1. Ouvre SKLauncher"
        echo "2. Selectionne le profil Fabric pour MC $MC_VERSION"
        echo "3. Verifie la version MC = $MC_VERSION (PAS $MC_VERSION.1, PAS $MC_VERSION.4)"
        echo "4. Lance le jeu"
    elif [[ "$LAUNCHER" =~ multimc|prism ]]; then
        echo "1. Ouvre MultiMC/Prism"
        echo "2. Verifie la version MC de l'instance = $MC_VERSION"
        echo "3. Lance le jeu"
    else
        echo "1. Ouvre ton launcher"
        echo "2. Force la version MC a $MC_VERSION (PAS 26.1.x, PAS 26.4+)"
        echo "3. Lance le jeu"
    fi
    echo "5. Verifie que 'Mod Menu' apparait dans le menu principal"
    echo "6. Ajoute le serveur : mc.alabalec.net port 25565 (ou lx-gaming:25565 via tailnet)"
    echo "7. Tape /register <password> puis /login <password> en jeu"
    echo ""
    echo "Si probleme : https://github.com/artlab-org/mc-modpack-client/issues"
else
    echo "=== Installation partielle ==="
    echo "$failed mods ont echoue. Re-lance le script pour retry."
fi
