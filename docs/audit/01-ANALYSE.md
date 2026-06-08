# 1 — Analyse

## 1.1 Verdict global

Le projet **fonctionne pour son auteur** (poste avec admin) et repose sur de **bonnes
fondations** : une vraie valeur (terminal moderne + CLI toolbox FOSS + desktop tiling
GlazeWM/Zebar), une structure modulaire, des prompts interactifs. Mais en l'état il
n'est **ni fiable, ni honnête, ni sûr par défaut** :

1. **Le code ment.** Aucun script ne vérifie `$LASTEXITCODE` après `winget`/`wsl`/`msiexec`.
   Comme ces exécutables natifs ne lèvent **pas** d'exception PowerShell, tous les
   `try/catch` qui les entourent sont **morts** : un échec d'installation est journalisé
   « SUCCESS » et le flux continue. `check.ps1` valide surtout des fichiers locaux du
   repo → fausse assurance. **C'est le défaut systémique n°1.**
2. **La doc ment.** Liens cassés dès le README (`PACKAGES.md`, `QUICK_START.md` pointés à
   la racine alors qu'ils sont dans `docs/`), fichiers fantômes (`IMPROVEMENTS.md`,
   `SUMMARY.md`, `BEFORE_AFTER.md`, `archive/`), claim « **100+ packages** » alors qu'il
   y a **59 entrées** (~50 uniques), « **MIT License** » sans fichier `LICENSE`.
3. **Le défaut est dangereux pour un poste pro.** La catégorie installée **par défaut**
   embarque qBittorrent (P2P → faute pro), Nmap/Wireshark (sniffing → EDR), Process
   Hacker (manip mémoire), RustDesk (accès distant non managé), Rufus/Ventoy (boot media).
   **`admin ≠ autorisation`** : même avec les droits, ces outils déclenchent le SOC ou
   violent la charte. C'est le risque qui **survit** à la disponibilité de l'admin.

## 1.2 Recalibration « admin disponible »

L'expert `corpo-constraints-realist` avait, sous l'hypothèse initiale (sans admin),
classé en **P0** le gate admin, la dépendance à winget et l'absence de palier zéro-admin.
**Avec admin disponible, ces constats chutent** — voici la correction officielle :

| Constat `corpo-fit` | Sévérité initiale | **Recalibrée (admin dispo)** | Pourquoi |
|---|---|---|---|
| `throw` admin à la ligne 1 | P0 | **P2** | Admin dispo → acceptable ; mais remplacer le `throw` par `#Requires -RunAsAdministrator` (échec propre et tôt) |
| Dépendance totale à winget | P0 | **P2** | winget marche avec admin ; un fallback reste un *bonus* de robustesse, pas un bloquant |
| Absence de Tier 0 zéro-admin | P0 | **P3** | Devient un **bonus de portabilité** (collègue sans admin), pas le correctif central |
| NerdFonts machine-wide | P1 | **P3** | Marche avec admin ; user-scope = simplification/bonus |
| WSL2 features + BIOS virtualisation | P1 | **P2** | Jouable avec admin ; reste à **détecter** le blocage GPO/BIOS et message clair au lieu de `throw`-and-continue |
| winget `--scope user` posé trop tard | P1 | **P3** | Cosmétique une fois l'admin acquis |

➡️ **Conséquence majeure** : la dimension `security-compliance` devient le **vrai** point
chaud n°1 côté « corpo », car elle ne dépend pas de l'admin.

## 1.3 Hiérarchie consolidée des constats

### 🔴 P0 — Cassé / dangereux (à traiter en premier)
| # | Constat | Source | Effort |
|---|---------|--------|--------|
| P0-1 | **Succès affiché sur échec** : aucun check `$LASTEXITCODE` ; `try/catch` morts autour de winget/wsl/msiexec ; tout le projet | powershell | medium |
| P0-2 | **`uninstall.ps1` destructeur** : `Remove-Item -Recurse -Force` sur `config/` **versionné** + désinstalle **winget** (composant OS) + purge des polices avec filtre faux | powershell + security | small |

### 🟠 P1 — Trompe l'utilisateur / conformité
| # | Constat | Source | Effort |
|---|---------|--------|--------|
| P1-1 | **Outils à risque RH/EDR installés par défaut** (qBittorrent, Nmap, Wireshark, Process Hacker, RustDesk, Rufus, Ventoy) sans avertissement | security | small |
| P1-2 | **Chaîne d'appro** : MSI WSL (+ installeur Docker) téléchargés via URL en dur et exécutés **sans vérif checksum/signature** | security | small |
| P1-3 | **`LICENSE` absent** malgré « MIT » annoncé → code de facto propriétaire | architecture/portfolio | trivial |
| P1-4 | **« 100+ packages » faux** (59 entrées, ~50 uniques) | architecture | small |
| P1-5 | **Liens cassés + fichiers fantômes** dans README/docs | architecture/portfolio | small |
| P1-6 | **`wsl.conf` jamais déployé** dans `/etc/wsl.conf` du distro → config WSL inerte (et brise l'idempotence : écrit hors repo via chemin relatif au CWD) | powershell | medium |
| P1-7 | **Aucun visuel** alors que GlazeWM/Zebar sont 100% visuels | portfolio | medium |
| P1-8 | **Claim « Safe — verified sources » trompeur** vu les outils embarqués | security | trivial |

> ⚠️ Correction factuelle (vérif adversariale) : le P1-6 ne « salit » le `config/wsl.conf`
> versionné **que si** on lance le script depuis `scripts/` (non documenté). Dans
> l'invocation documentée (CWD = racine), `..\config\wsl.conf` pointe **hors du repo**.
> Le défaut central (config jamais déployée dans le distro) tient quand même.

### 🟡 P2 — Qualité / maintenabilité / idempotence
- `check.ps1` : fausse confiance (valide des fichiers locaux ; filtre polices faux → `*Cascadia Code*` ne matche pas `CaskaydiaCove*`).
- **BOM UTF-8** écrit dans des fichiers lus par Linux (`wsl.conf`, `.sh`) → parsing cassé.
- `#Requires` absent partout sauf le check runtime d'`install.ps1`.
- Détection du blocage virtualisation (WSL2/Docker) manquante → `throw`/erreur au lieu d'un message clair. + note **licence Docker Desktop** en entreprise.
- **`Write-Log` dupliqué 12×** (+ création `logs/`, pattern try/catch) → module partagé.
- **Listes de paquets codées en dur** (~87 lignes de hashtables) → manifeste déclaratif (tue aussi la divergence du compteur).
- **Aucune CI**, **aucun test Pester** (le seul fichier sous `scripts/tests/` est un reliquat komorebi).
- **Gouvernance absente** : `CONTRIBUTING`/`SECURITY`/`CODE_OF_CONDUCT`/templates.
- `requirements.txt` = **prose mal nommée** (pip échouerait) ; `.gitignore` est un template **Python** sur un projet **PowerShell**.
- Incohérence de langue FR/EN, surcharge d'emojis, sections d'auto-félicitation.
- `Confirm-Action` (Read-Host) : en non-interactif, l'entrée vide = défaut → installs/reboot non voulus. Ajouter `-Unattended`/`-DryRun`.

### 🟢 P3 — Polissage / bonus
- Tier 0 zéro-admin portable (Scoop user-scope / binaires) — **bonus** pour collègue sans admin.
- NerdFonts user-scope, badges, TOC, FAQ (« faut-il l'admin ? » en tête).
- SemVer + `CHANGELOG` + releases ; bootstrap `irm | iex` ; section « Why not winutil/dotfiles ? ».
- Paramètres `-Verbose`/`-Fix` déclarés mais non implémentés (interface trompeuse).

## 1.4 Ce qui est déjà bien (à conserver)
- Modularité par composant (`scripts/install-*.ps1`).
- Prompts interactifs Y/N par catégorie + logging horodaté.
- Conventional Commits déjà utilisés (`feat:`/`fix:`/`refactor:`) → SemVer automatisable.
- `.pre-commit` avec PSScriptAnalyzer déjà déclaré (manque juste la CI qui le garantit).
- Le **cœur de valeur** (CLI toolbox FOSS + desktop tiling Gruvbox) est réel et différenciant.
