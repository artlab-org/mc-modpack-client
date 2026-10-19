# mc-modpack-client — Client modpack for artlab Minecraft (MC 26.3)

Modpack Fabric pour rejoindre **artlab Minecraft server** (MC 26.3).

## Installation

1. Installer un launcher (MultiMC, Prism, CurseForge App officiel, ou Mojang Launcher avec Fabric).
2. Télécharger **MC 26.3** vanilla.
3. Installer **Fabric Loader** pour MC 26.3 :
   - Via [fabricmc.net/use/installer](https://fabricmc.net/use/installer/)
4. Déposer le contenu de ce repo dans le dossier `.minecraft/` du launcher.
5. **Activer le shader pack** `ComplementaryReimagined` dans `Options > Video Settings > Shader Packs` (Iris).
6. Lancer le jeu et rejoindre `mc.alabalec.net` (port 25565).

## Contenu

| Dossier | Contenu |
|---|---|
| `mods/` | Mods Fabric à installer côté client |
| `config/` | Configs Sodium, Iris, Lithium, Distant Horizons, etc. |
| `shaderpacks/` | ComplementaryReimagined + alternatives |
| `resourcepacks/` | Crying Portals (portails nether translucides) |
| `.fabric/` | Loader profile (référence) |

## Mods client (compatibles MC 26.3 + Fabric)

| Mod | Rôle | Side |
|---|---|---|
| Fabric API | Loader Fabric | both |
| Sodium | Rendu optimisé (x2-4 FPS vs vanilla) | client |
| Iris | Chargeur de shaders OptiFine-compatibles | client |
| Mod Menu | UI config mods | client |
| Cloth Config | API config UI pour Sodium/Iris | client |
| FerriteCore | Optimisation mémoire | both |
| Lithium | Optimisation physique/IA/tick | both |
| Krypton | Optimisation réseau (NATS, packet) | both |
| Distant Horizons | LOD chunks lointains (render distance++) | both |
| Fabric Language Kotlin | Dépendance de certains mods | both |
| Chunky | Sélectionner zone de pre-gen | client |

## Compatibilité serveur

Le serveur attendu est sur MC 26.3 + Fabric + EasyAuth + Vanish.
Si le serveur utilise `OnlineMode=false` (mode crack), utiliser `TLauncher`, `MultiMC` en mode offline, ou un compte Microsoft valide.

## Upgrade

Pour ajouter un mod :
1. Télécharger le `.jar` sur Modrinth/CurseForge (assurer compatibilité MC 26.3 + Fabric).
2. Calculer son SHA256 :
   ```bash
   sha256sum mods/nouveau-mod.jar
   ```
3. Mettre à jour ce README + commit + push.

## Notes

- **OptiFine est incompatible avec Sodium** sur Fabric. Sodium + Iris = l'équivalent moderne.
- **Distant Horizons** permet une render distance quasi-infinie mais demande plus de RAM client (2-4 GB alloué recommandé).
- Le `server.properties` côté serveur a `online-mode=false` → tout pseudo fonctionne (crack + premium).
- Si l'écran de login EasyAuth apparaît : `/register <password>` puis `/login <password>` à la première connexion.

## Version

v1.0.0 — bundle initial MC 26.3 + Fabric 0.16.3
