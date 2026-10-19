# mc-modpack-client — Modpack client artlab Minecraft (MC 26.3 Fabric)

**Modpack Fabric pour rejoindre le serveur artlab Minecraft (MC 26.3).**

> ⚠️ **Sans ce modpack, tu ne peux pas rejoindre le serveur.**
> Le serveur détecte ton client et t'envoie un message d'erreur avec ce lien si tu n'as pas les mods installés.

---

## Sommaire

1. [Pré-requis](#pré-requis)
2. [Installation rapide (automatique)](#installation-rapide-automatique)
3. [Installation manuelle](#installation-manuelle)
4. [Liens Modrinth (téléchargement direct)](#liens-modrinth-pour-téléchargement-direct)
5. [Accès au serveur](#accès-au-serveur)
6. [Compatibilité launcher](#compatibilité-launcher)
7. [Upgrade](#upgrade)
8. [Notes](#notes)

---

## Pré-requis

- **Java 21 ou plus récent** (MC 26.3 utilise Java 25 LTS)
- **Minecraft Java Edition 26.3** installé via ton launcher
- Un des launchers suivants :
  - **Minecraft Launcher officiel** (Microsoft)
  - **TLauncher** (crack)
  - **SKLauncher** (crack)
  - **MultiMC / Prism Launcher** (open-source)
- 1 GB d'espace disque (mods = ~50 MB)
- 4 GB RAM alloués au jeu (recommandé 6 GB pour Distant Horizons)

---

## Installation rapide (automatique)

### Windows (oneliner PowerShell)

Ouvre PowerShell (touche Windows, tape `powershell`, Entrée), puis colle :

```powershell
irm https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/install.ps1 | iex
```

Le script :
1. Télécharge tous les mods depuis Modrinth CDN
2. Vérifie les SHA512
3. Copie dans ton dossier `.minecraft/mods/`
4. Confirme l'installation

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/install.sh | bash
```

> Le script supporte `--dir <path>` pour cibler un dossier `.minecraft` custom (MultiMC/Prism).

### Désinstallation

```bash
# Windows
irm https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/uninstall.ps1 | iex

# Linux / macOS
bash <(curl -fsSL https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/uninstall.sh)
```

---

## Installation manuelle

Si tu préfères installer les mods à la main (ou si l'install auto ne marche pas) :

### Étape 1 — Installer Fabric Loader 0.19.5

1. Télécharge [fabric-installer.jar](https://maven.fabricmc.net/net/fabricmc/fabric-loader/0.19.5/fabric-loader-0.19.5.jar)
2. Lance-le avec Java 21+ :
   ```bash
   java -jar fabric-installer.jar client -mcversion 26.3 -loader 0.19.5
   ```
3. Sélectionne ton profil MC 26.3 vanilla, puis clique **Install**

### Étape 2 — Télécharger les mods

Va sur [Modrinth](https://modrinth.com), cherche chaque mod, vérifie la compatibilité MC 26.3 + Fabric, télécharge le `.jar`.

**OU** utilise les liens directs dans le tableau [ci-dessous](#liens-modrinth-pour-téléchargement-direct).

### Étape 3 — Copier les mods

Copie les 12 fichiers `.jar` dans ton dossier `.minecraft/mods/` :

| OS | Chemin typique |
|---|---|
| Windows | `%APPDATA%\.minecraft\mods\` (en général `C:\Users\<ton_nom>\AppData\Roaming\.minecraft\mods\`) |
| Linux | `~/.minecraft/mods/` |
| macOS | `~/Library/Application Support/minecraft/mods/` |

### Étape 4 — Lancer le jeu

1. Ouvre ton launcher (officiel, TLauncher, SKLauncher, MultiMC, Prism)
2. Sélectionne le profil **Fabric Loader 0.19.5** (ou créé-en un nouveau en pointant vers la version Fabric)
3. Lance le jeu
4. Tu dois voir l'écran **Mod Menu** dans le menu principal → ça confirme que les mods sont chargés

---

## Liens Modrinth (pour téléchargement direct)

Tous les mods ont été téléchargés depuis **Modrinth** (CDN officiel). Tu peux vérifier chaque SHA512 sur la page Modrinth du mod.

| Mod | Version | Taille | Page Modrinth |
|---|---|---:|---|
| [fabric-api](https://modrinth.com/mod/fabric-api) | 0.163.0+26.3 | 1,774,707 bytes |
| [sodium](https://modrinth.com/mod/sodium) | mc26.3-0.9.3-beta.1-fabric | 1,912,496 bytes |
| [iris](https://modrinth.com/mod/iris) | 1.11.7+26.3-fabric | 2,850,938 bytes |
| [lithium](https://modrinth.com/mod/lithium) | mc26.3-0.26.2-fabric | 914,543 bytes |
| [ferrite-core](https://modrinth.com/mod/ferrite-core) | 9.0.0-fabric | 72,677 bytes |
| [krypton](https://modrinth.com/mod/krypton) | 0.3.2 | 268,849 bytes |
| [modmenu](https://modrinth.com/mod/modmenu) | 21.0.0 | 856,779 bytes |
| [cloth-config](https://modrinth.com/mod/cloth-config) | 26.3.159+fabric | 1,135,009 bytes |
| [distanthorizons](https://modrinth.com/mod/distanthorizons) | 3.3.4-26.3 | 28,476,894 bytes |
| [fabric-language-kotlin](https://modrinth.com/mod/fabric-language-kotlin) | 1.14.2+kotlin.2.4.21 | 8,142,878 bytes |
| [viafabric](https://modrinth.com/mod/viafabric) | 0.4.22+186-26.x | 5,914,365 bytes |
| [chunky](https://modrinth.com/mod/chunky) | 1.5.3 | 354,095 bytes |
| [easyauth](https://modrinth.com/mod/easyauth) | 3.4.4 | 24,257,433 bytes |
| [vanish](https://modrinth.com/mod/vanish) | 1.6.16+26.3 | 1,256,413 bytes |

### Téléchargement manuel en lot

Pour télécharger tous les mods d'un coup (PowerShell) :

```powershell
$mods = @(
  @{ slug = "fabric-api"; version = "0.163.0+26.3" },
  @{ slug = "sodium"; version = "mc26.3-0.9.3-beta.1-fabric" },
  @{ slug = "iris"; version = "1.11.7+26.3-fabric" },
  @{ slug = "lithium"; version = "mc26.3-0.26.2-fabric" },
  @{ slug = "ferrite-core"; version = "9.0.0-fabric" },
  @{ slug = "krypton"; version = "0.3.2" },
  @{ slug = "modmenu"; version = "21.0.0" },
  @{ slug = "cloth-config"; version = "26.3.159+fabric" },
  @{ slug = "distanthorizons"; version = "3.3.4-26.3" },
  @{ slug = "fabric-language-kotlin"; version = "1.14.2+kotlin.2.4.21" },
  @{ slug = "viafabric"; version = "0.4.22+186-26.x" },
  @{ slug = "chunky"; version = "1.5.3" }
)

foreach ($mod in $mods) {
  $apiUrl = "https://api.modrinth.com/v2/project/$($mod.slug)/version?game_versions=%5B%2226.3%22%5D&loaders=%5B%22fabric%22%5D"
  $version = (Invoke-RestMethod -Uri $apiUrl)[0]
  $file = $version.files[0]
  Write-Host "Téléchargement $($mod.slug)..." -ForegroundColor Cyan
  Invoke-WebRequest -Uri $file.url -OutFile "$env:APPDATA\.minecraft\mods\$($file.filename)"
}
```

---

## Accès au serveur

- **Tailnet** : `lx-gaming:25565` (100.83.118.18:25565) — pour les accès internes
- **Public** : `mc.alabalec.net:25565` — ⚠️ pas encore routé publiquement (work in progress)

### Première connexion

1. Ajoute le serveur dans ton launcher : `lx-gaming` port `25565`
2. Connecte-toi avec **n'importe quel pseudo** (online-mode=false → crack + premium OK)
3. Tape `/register <ton_mot_de_passe>` (ex : `/register abc123`)
4. Tape `/login <ton_mot_de_passe>` pour te reconnecter
5. Tu peux maintenant jouer !

Si tu changes de pseudo, refais `/register` avec le nouveau pseudo.

### Commandes admin

Les admins (ElNadou, ElPouleto, arthur) ont accès à :
- `/vanish` — devenir invisible
- `/gamemode`, `/tp`, `/give`, `/effect`, `/weather`, `/time`
- `/op <pseudo>` — promouvoir un joueur (niveau 4 = tout)

---

## Compatibilité launcher

Testé sur :
- ✅ **Minecraft Launcher officiel** (Microsoft) — profil Fabric Loader 0.19.5
- ✅ **Prism Launcher** — version Fabric Loader 0.19.5
- ✅ **MultiMC** — instance Fabric Loader 0.19.5
- ✅ **TLauncher** — version Fabric 26.3 (TLauncher 4+)
- ✅ **SKLauncher** — version Fabric 26.3 (1.4+)
- ⚠️ **Badlion Client** — non testé, devrait marcher mais peux pas garantir
- ❌ **Lunar Client / Badlion / autres clients moddés** — incompatibles, ces launchers moddés ne supportent pas Fabric

---

## Upgrade

Pour mettre à jour un mod :

1. Va sur sa [page Modrinth](https://modrinth.com) (lien dans le tableau ci-dessus)
2. Vérifie que la version supporte **MC 26.3 + Fabric**
3. Télécharge le nouveau `.jar`
4. Remplace l'ancien dans `.minecraft/mods/`
5. Relance le jeu

Les **SHA512** sont vérifiés par le script d'install automatique pour éviter les corruptions.

---

## Notes

### Pourquoi pas OptiFine ?

OptiFine est **mort sur Fabric** : il n'a pas de build compatible Sodium, et Sodium est devenu le standard en 2024+. Le combo **Sodium + Iris** est l'équivalent moderne : moteur de rendu optimisé + shaders OptiFine-compatibles.

### Distant Horizons (LOD)

Ce mod permet une render distance quasi-infinie en générant des chunks lointains en arrière-plan. Pour en profiter :

1. Va dans `Options > Video Settings > Distant Horizons`
2. Augmente `Render Distance Horizontal` (en chunks) jusqu'à 256 ou 512
3. Alloue **au moins 4 GB de RAM** au jeu (Edit Profile → JVM Args → `-Xmx4G`)

### Voir à travers les portails du Nether

Pas de mod Fabric dédié compatible MC 26.3 à ce jour. Tu peux utiliser **Crying Portals** (resource pack) pour rendre les portails translucides.

### Java 25 LTS

MC 26.3 utilise Java 25 LTS. Si ton launcher propose une option « Java version », choisis Java 21+ (de préférence Java 25).

---

## Compatibilité serveur

Le serveur attendu doit tourner avec :
- **Fabric Loader 0.19.5** (auto-installé via `itzg/minecraft-server`)
- **Mods serveur** (déjà installés) : EasyAuth, Vanish, ViaFabric, Lithium, FerriteCore, Krypton, Distant Horizons

Si le serveur est down, contacte un admin.

---

---

## Troubleshooting — le jeu ne se lance pas

Si MC crashe au lancement avec le modpack, **99% du temps c'est l'une de ces 3 causes** :

### 1. Mauvaise version MC chargée (cause #1)

Le launcher Mojang officiel télécharge la dernière version stable automatiquement (en ce moment **26.5+** qui peut être incompatible avec les mods 26.3). **Tu dois forcer MC 26.3** :

1. Ouvre le launcher Mojang
2. À côté de **Jouer**, clique sur la version affichée (probablement "Latest release" ou un X.Y+)
3. Sélectionne **26.3** dans le menu déroulant
4. Relance → le modpack Fabric devrait charger

Vérification : le serveur tourne en MC **26.3 protocol 777**. Si tu essaies 26.4+, le serveur te kickera avec "Incompatible client".

### 2. Mauvais Java utilisé (cause #2)

MC 26.3 utilise Java 25 LTS. Si ton launcher utilise Java 8 ou 11 (par défaut sur Windows), Java crash.

**Vérification** : ouvre un terminal et tape `java -version`. Tu dois voir Java 21+ (idéalement 25).

**Fix** : dans le launcher Mojang → **Installations** → choisis ton profil Fabric → **Edit** → **Java version** → change vers 21+ (bouton "..." à droite du champ Java executable). Si Java 21+ n'est pas listé, installe-le via Adoptium (https://adoptium.net/) et pointe le launcher vers le chemin complet (`C:\Program Files\Eclipse Adoptium\jdk-25.0.4.1-hotspot\bin\javaw.exe`).

### 3. Fabric Loader pas installé ou mauvaise version (cause #3)

Le modpack a besoin de **Fabric Loader 0.19.5**. Si tu utilises un profil vanilla sans Fabric Loader :

1. Va sur https://maven.fabricmc.net/net/fabricmc/fabric-loader/0.19.5/fabric-loader-0.19.5.jar
2. Télécharge `fabric-loader-0.19.5.jar`
3. Lance-le avec Java 21+ : `java -jar fabric-loader-0.19.5.jar client -mcversion 26.3 -loader 0.19.5`
4. Sélectionne ton profil MC 26.3, clique **Install**

Ou via MultiMC/Prism : ajoute une instance "Fabric" depuis le launcher, sélectionne version 26.3, installe, mets les mods dans `.minecraft/mods/`.

---



### 4. SKLauncher a installé ses propres mods 26.1 par défaut

Si tu utilises **SKLauncher** (ou TLauncher avec profil Fabric), le launcher peut **injecter ses propres mods** (Zoomify, Controlify, YetAnotherConfigLib, ViaFabric-mc26-1) qui sont pour **MC 26.1** et bloquent le boot MC 26.3 avec :

```
Incompatible mods found!
net.fabricmc.loader.impl.FormattedException: Some of your mods are incompatible with the game or each other!
```

**Fix** : réinstalle mon modpack avec `-Clean` (ça wipe les mods 26.1) :

```powershell
irm https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/install.ps1 | iex -args @{Launcher='sklauncher'; Clean=$true}
```

OU manuellement :
1. Va dans `versions\<ton_profil_fabric>\mods\`
2. Supprime tous les .jar qui ne sont PAS dans la liste de mon modpack :
   `fabric-api`, `sodium`, `iris`, `lithium`, `ferrite-core`, `krypton`, `modmenu`, `cloth-config`, `distanthorizons`, `fabric-language-kotlin`, `viafabric`, `chunky`
3. Relance MC

Note : `ViaFabric` a 2 versions (`viafabric` pour 26.3 et `viafabric-mc26-1` pour 26.1). Tu dois garder uniquement la version **26.3**.


## Crash report à m'envoyer si rien ne marche

Si après ces 3 fixes le jeu crashe encore, envoie-moi :
1. **logs/latest.log** depuis `.minecraft/logs/latest.log` (ou `.minecraft/versions/1.21.x-yyyy.z.z/latest.log`)
2. **crash-reports/latest.txt** depuis `.minecraft/crash-reports/`
3. **Version MC** exacte (en haut du launcher)
4. **Version Java** (`java -version` dans un terminal)
5. **OS** + version launcher (officiel/MultiMC/Prism/TLauncher/SKLauncher)
6. **Contenu de .minecraft/mods/** (`ls .minecraft/mods/`)

Avec ça je peux diagnostiquer en 30s.


---

## License

MIT — voir [LICENSE](./LICENSE).
