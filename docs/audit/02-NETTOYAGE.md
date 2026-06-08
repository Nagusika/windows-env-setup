# 2 — Nettoyage

Actions de nettoyage **immédiates et à faible risque** (avant toute amélioration de fond).
Objectif : un dépôt qui **dit la vérité** et ne contient que des fichiers utiles.
Principe : **KISS** — on supprime plus qu'on n'ajoute.

## 2.1 Fichiers à supprimer (artefacts de dev / reliquats)

| Fichier | Raison |
|---------|--------|
| [GLAZEWM_ZEBAR_INTEGRATION.md](../../GLAZEWM_ZEBAR_INTEGRATION.md) | Rapport d'avancement perso (« Implementation Complete ✅ »), pas de la doc produit. Le contenu utile est déjà dans [docs/GLAZEWM_ZEBAR_GUIDE.md](../GLAZEWM_ZEBAR_GUIDE.md). |
| [docs/COMMIT_PLAN.md](../COMMIT_PLAN.md) | Plan de commits atomiques = artefact de process, n'a rien à faire dans la doc utilisateur. |
| [scripts/tests/clean-before-commit.ps1](../../scripts/tests/clean-before-commit.ps1) | Reliquat **komorebi** (déjà retiré du projet) ; et ce n'est **pas** un test. Supprimer le dossier `scripts/tests/` (les vrais tests Pester iront dans `tests/`, cf. roadmap M4). |

## 2.2 Fichiers à renommer / remplacer

| Action | Détail |
|--------|--------|
| `requirements.txt` → `docs/PREREQUISITES.md` | C'est de la **prose** décrivant les prérequis, pas un fichier pip. Le garder sous ce nom trompe tout lecteur/outil (`pip install -r` échouerait). |
| Remplacer `.gitignore` | L'actuel est un template **Python** (83 lignes de `__pycache__`, `.venv`, `*.egg-info`…) sans rapport. Le remplacer par un `.gitignore` **PowerShell/Windows** minimal : `logs/`, `*.log`, `.vs/`, artefacts winget/temp. (`logs/` est déjà correctement ignoré — bon point à conserver.) |

## 2.3 Fichiers à créer (combler les promesses)

| Fichier | Contenu |
|---------|---------|
| `LICENSE` | Texte **MIT** complet, année **2026**, titulaire **Nagusika**. Débloque le badge licence GitHub et lève l'ambiguïté juridique (P1-3). |
| `SECURITY.md` | Politique de signalement + **clause de conformité** : « Plusieurs paquets (sniffing réseau, accès distant, P2P, médias bootables, conteneurs chiffrés) peuvent déclencher l'EDR/DLP ou enfreindre la charte de votre employeur. Vérifiez votre politique IT/RH ; vous êtes responsable de votre usage. » (P1-1, P1-8) |
| `CONTRIBUTING.md` | Y déplacer le setup `pre-commit` (actuellement dans le README), conventions de commit, lancement des tests. |

## 2.4 Corrections documentaires (la doc doit dire la vérité)

Dans [README.md](../../README.md) :
- **Liens** : `[PACKAGES.md](PACKAGES.md)` → `[PACKAGES.md](docs/PACKAGES.md)` ; idem `QUICK_START.md`.
- **Bloc arborescence** (lignes ~96-121) : retirer `IMPROVEMENTS.md`, `PACKAGES.md` (racine), `SUMMARY.md` qui n'existent pas ; refléter l'arbo réelle.
- **« 100+ »** → chiffre réel (`~50`) **partout** (et idéalement généré depuis le manifeste, cf. M3 — plus jamais de divergence).
- **« 🛡️ Safe - All packages from verified sources »** → reformuler (« sources via winget ; certains paquets peuvent enfreindre la politique de votre entreprise — voir SECURITY.md »).
- Retirer les conclusions auto-élogieuses (« You're Done! Enjoy! », « ✅✅✅ »).

Dans [docs/README.md](../README.md) :
- Supprimer la référence au dossier `archive/` (11 guides) inexistant.
- Aligner les liens sur les fichiers réellement présents.

Dans [docs/PROJECT_STRUCTURE.md](../PROJECT_STRUCTURE.md) :
- Réécrire l'arborescence (manque `install-glazewm.ps1`, `install-zebar.ps1`, `install-winget.ps1`, `check.ps1`, les configs glazewm/zebar ; mentionne des fichiers komorebi/SUMMARY/BEFORE_AFTER disparus).

## 2.5 Correctifs de sécurité destructrice (urgents mais simples)

Dans [uninstall.ps1](../../uninstall.ps1) :
- **Supprimer** `Remove-ConfigurationFiles` qui efface `config/` (versionné). Ne cibler que les configs **déployées** (`$env:USERPROFILE\.glzr`, profils Terminal sous `$env:LOCALAPPDATA\Packages\…`).
- **Supprimer** `Uninstall-Winget` (ou la mettre derrière un switch `-RemoveWinget` à défaut faux) : on ne désinstalle pas un composant Windows que le projet n'a pas posé.
- **Corriger** le filtre de polices : cibler les fichiers réellement installés (`*NerdFont*` / `CaskaydiaCove*`), pas `*Cascadia Code*` (qui rate les Nerd Fonts et risque la police système).

> Ces trois correctifs `uninstall.ps1` sont du nettoyage **et** du P0-2 — à faire dès maintenant.

## 2.6 Definition of Done du nettoyage
- [ ] `git status` propre, plus aucun fichier « meta/process » livré.
- [ ] Tous les liens markdown du README résolvent (vérifiable : `markdown-link-check`).
- [ ] `LICENSE` présent, badge MIT affiché par GitHub.
- [ ] Aucun chiffre invérifiable dans la doc.
- [ ] `uninstall.ps1` ne touche plus à `config/` ni à winget.
