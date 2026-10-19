#!/usr/bin/env bash
set -euo pipefail
MODS_DIR="${HOME}/.minecraft/mods"
SLUGS=("fabric-api" "sodium" "iris" "lithium" "ferrite-core" "krypton" "modmenu" "cloth-config" "distanthorizons" "fabric-language-kotlin" "viafabric" "chunky")
echo "Suppression des mods artlab de $MODS_DIR"
for slug in "${SLUGS[@]}"; do
    for f in "$MODS_DIR"/*${slug}*; do
        [ -f "$f" ] && echo "  Remove $(basename "$f")" && rm -f "$f"
    done
done
echo "Done."
