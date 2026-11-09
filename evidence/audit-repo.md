# Audit repo client — `artlab-org/mc-modpack-client` (carte TADA #1793)

Périmètre audité : `mods/manifest.json`, `install.sh`, `install.ps1`, `README.md` (+ `mods/checksums.txt` en contrôle croisé).
Base : `main` @ `f9311f3` — branche de travail : `fix/readme-modpack-facultatif`.
Sources de contrôle : fichiers du dépôt, API Modrinth (`api.modrinth.com/v2`), API Fabric (`meta.fabricmc.net/v2`), empreintes recalculées des `.jar` présents.

| fichier | contrôle | verdict | preuve |
|---|---|---|---|
| `mods/manifest.json` | Nombre de mods déclarés | conforme | `python3 -c "import json;print(len(json.load(open('mods/manifest.json'))['mods']))"` → `13` |
| `mods/manifest.json` | Liste des 13 slugs | conforme | identique à `install.sh` (`MODS=(`) et `install.ps1` (`$MODS = @(`) : comparaison programmatique → `manifest=13 install.sh=13 install.ps1=13 | identique manifest: sh=True ps=True` (diff des ensembles vide) |
| `mods/manifest.json` | sha512 de chaque `.jar` livré dans `mods/` | conforme | recalcul sha512 sur les 13 fichiers → `manifest entries: 13 sha512 ok: 13 mismatch: 0 absents: 0` |
| `mods/manifest.json` | Correspondance upstream Modrinth (version, sha512, taille) des 13 entrées | conforme | 13 requêtes `/v2/project/<slug>/version?loaders=["fabric"]&game_versions=["26.3"]` → `CONFORME` ×13, ex. `plasmo-voice CONFORME v=fabric-26.3-2.1.17 id=vKP6gBRn sha512=ok taille=12248022/12248022` |
| `mods/manifest.json` | `plasmo-voice` : version / version_id / sha512 / taille | conforme | `GET https://api.modrinth.com/v2/version/vKP6gBRn` → `fabric-26.3-2.1.17`, sha512 `00090edb…f83`, taille `12248022` — identiques au manifeste, au `.jar` sur disque et au README |
| `mods/manifest.json` | `mc_version` | conforme | `26.3` = défaut de `install.sh` (`MC_VERSION="${MC_VERSION:-26.3}"`) et de `install.ps1` (`$Version = "26.3"`) |
| `mods/manifest.json` | `fabric_loader` | **divergence → corrigé** | manifeste `0.16.3` contre `0.19.5` dans README (9 occurrences) et `install.ps1:84,383` ; `GET https://meta.fabricmc.net/v2/versions/loader/26.3` → `0.19.5 présent pour MC 26.3 : True` ; alignement sur `0.19.5` (une seule ligne modifiée) |
| `install.sh` | Liste des mods installée | conforme | `MODS=(` (install.sh:229-243) = 13 slugs, contenu et ordre identiques au manifeste |
| `install.sh` | Épinglage de `plasmo-voice` | conforme | `PINNED_VERSIONS=("plasmo-voice:vKP6gBRn")` (install.sh:249-251) → `vKP6gBRn` = version_id de la stable `fabric-26.3-2.1.17` (jamais la bêta `2.2.0-beta.2`) |
| `install.ps1` | Liste des mods installée | conforme | `$MODS = @(` (install.ps1:268-282) = 13 slugs identiques au manifeste |
| `install.ps1` | Épinglage de `plasmo-voice` | conforme | `$script:PinnedVersions = @{ "plasmo-voice" = "vKP6gBRn" }` (install.ps1:288-290) |
| `install.sh`, `install.ps1` | Dépendance au manifeste | conforme | `grep -rn "manifest" install.sh install.ps1 uninstall.sh uninstall.ps1` → aucune référence : les scripts interrogent l'API Modrinth, le champ `fabric_loader` n'est donc pas consommé par eux |
| `README.md` | Tableau des versions / tailles | conforme | 15 lignes (13 mods client + `easyauth` + `vanish` cote serveur) ; comparaison automatique version+tailles vs manifeste → `lignes tableau README=15 | divergences version/taille vs manifeste=0` |
| `README.md` | Compte « 13 mods » et taille totale | conforme | total manifeste `64922252` o = **61,9 Mio** → « ~62 Mio » exact ; compte 13 identique aux 3 autres fichiers |
| `README.md` | `plasmo-voice` : version, version_id, sha512, lien CDN | conforme | section « Chat vocal » : `2.1.17 (fabric-26.3-2.1.17)` / `vKP6gBRn` / sha512 `00090edb…f83` / `https://cdn.modrinth.com/data/1bZhdhsH/versions/vKP6gBRn/plasmovoice-fabric-26.3-2.1.17.jar` — identiques au manifeste et à l'API |
| `README.md` | **« Sans ce modpack, tu ne peux pas rejoindre le serveur »** | **divergence → corrigé** | contradiction avec la mention « côté serveur, le mod n'est pas obligatoire » (README:262) et avec la communication du site (modpack facultatif) ; remplacé par « Ce modpack est facultatif pour rejoindre le serveur » + les 4 apports ; `grep -rn "ne peux pas rejoindre" README.md` → `0 occurrence` |
| `README.md` | Formulation « facultatif » + 4 apports | corrigé | `grep -rni "facultatif" README.md` → 3 lignes (README:3, README:5, README:269) ; apports énoncés README:8-11 : **Optimisation**, **Distant Horizons**, **Shaders**, **Chat vocal de proximité** |
| `README.md` | Loader Fabric indiqué | conforme | `0.19.5` (README) et `meta.fabricmc.net/v2/versions/loader/26.3` → `0.19.5 présent pour MC 26.3 : True` |
| `mods/checksums.txt` | Contrôle croisé des empreintes | conforme | 13 lignes sha512 + 13 lignes sha256 (une paire par `.jar`) : `sha512sum -c checksums.txt` → `13 OK` (code retour 0, les 13 lignes sha256 signalées « improperly formatted » sans échec) ; `sha256sum -c checksums.txt` → `13 OK` |

## Corrections appliquées

1. `README.md` — message d'intro : « modpack obligatoire pour rejoindre » → « modpack **facultatif** », avec la liste des 4 apports (optimisation, Distant Horizons, shaders, chat vocal de proximité) et la perte de ces améliorations sans le pack, dont la voix.
2. `README.md:269` — formulation de la section « Chat vocal » alignée sur « facultatif ».
3. `mods/manifest.json:4` — `fabric_loader` : `0.16.3` → `0.19.5` (seule divergence réelle hors README, démontrée ci-dessus ; les scripts n'utilisent pas ce champ).

Aucune modification : noms de fichiers de mods, hashes de téléchargement, URLs de release, listes de mods, scripts d'installation.
