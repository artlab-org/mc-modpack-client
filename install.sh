#!/usr/bin/env bash
# artlab MC modpack install script (Linux/macOS)
# Usage: curl -fsSL https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/install.sh | bash
# Or:    bash install.sh [--dir <minecraft-dir>]

set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main"
MINECRAFT_DIR="${HOME}/.minecraft"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir) MINECRAFT_DIR="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

MODS_DIR="${MINECRAFT_DIR}/mods"

echo ""
echo "=== artlab MC modpack installer ==="
echo "Mods target dir: $MODS_DIR"
echo ""

# Verify Minecraft dir
if [ ! -d "$MINECRAFT_DIR" ]; then
    echo "Error: $MINECRAFT_DIR not found" >&2
    echo "Lance une fois Minecraft 26.3 pour creer le dossier." >&2
    exit 1
fi

# Verify Java
if ! command -v java >/dev/null 2>&1; then
    echo "Error: java not in PATH" >&2
    echo "Installe Java 21+ : https://adoptium.net/" >&2
    exit 1
fi
java -version 2>&1 | head -1 | sed "s/^/Java detecte: /"

mkdir -p "$MODS_DIR"

# Mods list
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
echo "Telechargement de ${#MODS[@]} mods depuis Modrinth..."

for slug in "${MODS[@]}"; do
    echo ""
    echo "[$slug]"
    api_url="https://api.modrinth.com/v2/project/$slug/version?game_versions=%5B%2226.3%22%5D&loaders=%5B%22fabric%22%5D"
    api_json=$(curl -fsS "$api_url" 2>&1) || {
        echo "  ERREUR API Modrinth pour $slug" >&2
        continue
    }

    # Get first version's first file URL + SHA512
    file_url=$(echo "$api_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['files'][0]['url'])" 2>/dev/null) || {
        echo "  Pas de version MC 26.3 Fabric pour $slug, skip"
        continue
    }
    file_name=$(echo "$api_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['files'][0]['filename'])")
    expected_sha=$(echo "$api_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['files'][0]['hashes']['sha512'])")
    version=$(echo "$api_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['version_number'])")

    dest="${MODS_DIR}/${file_name}"
    if [ -f "$dest" ]; then
        actual=$(sha512sum "$dest" | awk "{print \$1}")
        if [ "$actual" = "$expected_sha" ]; then
            echo "  Deja installe: $file_name ($version)"
            continue
        fi
    fi

    echo "  DL $file_name ($version)..."
    tmp=$(mktemp)
    if ! curl -fsSL -o "$tmp" "$file_url"; then
        echo "  ERREUR telechargement" >&2
        rm -f "$tmp"
        continue
    fi
    actual=$(sha512sum "$tmp" | awk "{print \$1}")
    if [ "$actual" = "$expected_sha" ]; then
        mv "$tmp" "$dest"
        echo "  OK $version"
    else
        echo "  SHA mismatch, skip" >&2
        rm -f "$tmp"
    fi
done

echo ""
echo "=== Installation terminee ==="
echo ""
echo "PROCHAINES ETAPES :"
echo "1. Ouvre ton launcher (officiel, MultiMC, Prism)"
echo "2. Selectionne le profil Fabric Loader 0.19.5"
echo "3. Lance Minecraft 26.3"
echo "4. Verifie que 'Mod Menu' apparait dans le menu principal"
echo "5. Ajoute le serveur : lx-gaming port 25565"
echo "6. Tape /register <password> puis /login <password> en jeu"
