#!/usr/bin/env bash
# artlab MC modpack uninstall (Linux/macOS)
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/uninstall.sh | bash
#   curl -fsSL ... | bash -s -- --launcher sklauncher
#   curl -fsSL ... | bash -s -- --dir /path/to/.minecraft

set -euo pipefail

LAUNCHER="auto"
DIR_OVERRIDE=""
SKLAUNCHER_BIN_DIR="${MC_SKLAUNCHER_BIN:-}"
PRISM_LAUNCHER_BIN_DIR="${MC_PRISM_BIN:-}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --launcher) LAUNCHER="$2"; shift 2 ;;
        --dir) DIR_OVERRIDE="$2"; shift 2 ;;
        --sklauncher-bin) SKLAUNCHER_BIN_DIR="$2"; shift 2 ;;
        --prism-bin) PRISM_LAUNCHER_BIN_DIR="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

echo "=== artlab MC modpack uninstall ==="

# Same launcher detection as install.sh (simplified inline)
detect_sklauncher() {
    if [[ -n "$SKLAUNCHER_BIN_DIR" && -d "$SKLAUNCHER_BIN_DIR" ]]; then echo "$SKLAUNCHER_BIN_DIR"; return 0; fi
    local c
    for c in "/mnt/c/Users/$USER/AppData/Roaming/.minecraft/versions" "$HOME/.minecraft/versions"; do
        [[ -d "$c" ]] && { echo "$c"; return 0; }
    done
    return 1
}
detect_prism_or_multimc() {
    local c
    for c in "$HOME/.local/share/PrismLauncher/instances" "$HOME/.local/share/multimc/instances" "$HOME/.multimc/instances" "$HOME/.prismlauncher/instances"; do
        [[ -d "$c" ]] && { echo "$c"; return 0; }
    done
    return 1
}

MODS_DIR=""
case "$LAUNCHER" in
    custom) MODS_DIR="$DIR_OVERRIDE" ;;
    sklauncher)
        if versions_dir=$(detect_sklauncher); then
            match=$(find "$versions_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while IFS= read -r d; do
                local n; n=$(basename "$d")
                if [[ "$n" == *"26.3"*fabric* ]] || [[ "$n" == *fabric*"26.3"* ]]; then
                    echo "$d/mods"
                    break
                fi
            done)
            [[ -n "$match" ]] && MODS_DIR="$match"
        fi
        ;;
    multimc|prism)
        if root=$(detect_prism_or_multimc); then
            inst=$(find "$root" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1)
            [[ -n "$inst" ]] && MODS_DIR="$inst/.minecraft/mods"
        fi
        ;;
    official|auto)
        MODS_DIR="$HOME/.minecraft/mods"
        ;;
esac

if [[ -z "$MODS_DIR" ]]; then
    echo "Erreur: impossible de determiner le dossier mods/ pour launcher=$LAUNCHER"
    echo "Utilise --dir <path> pour specifier."
    exit 1
fi

echo "Mods dir: $MODS_DIR"
echo "Suppression..."

# Each mod slug as substring to match filename
SLUGS=("fabric-api" "sodium" "iris" "lithium" "ferrite-core" "krypton" "modmenu" "cloth-config" "distanthorizons" "fabric-language-kotlin" "viafabric" "chunky")

count=0
for slug in "${SLUGS[@]}"; do
    for f in "$MODS_DIR"/*${slug}*; do
        if [[ -f "$f" ]]; then
            echo "  rm $(basename "$f")"
            rm -f "$f"
            count=$((count+1))
        fi
    done
done

echo ""
echo "$count fichiers supprimes."
