# Structure du projet

## Arborescence réelle

```
windows-env-setup/
├── install.ps1                     # Installation interactive complète
├── uninstall.ps1                   # Désinstallation
├── check.ps1                       # Vérification de l'environnement
│
├── scripts/                        # Scripts d'installation par composant
│   ├── install-winget.ps1
│   ├── install-git.ps1
│   ├── install-github-cli.ps1
│   ├── install-terminal.ps1
│   ├── install-nerdfonts.ps1
│   ├── install-glazewm.ps1
│   ├── install-zebar.ps1
│   ├── install-wsl.ps1
│   └── install-docker.ps1
│
├── config/                         # Fichiers de configuration
│   ├── wsl.conf
│   ├── wsl-font-config.sh
│   ├── terminal-settings.json
│   ├── winget-settings.json
│   ├── docker-settings.json
│   ├── glazewm-config.yaml
│   ├── zebar-with-glazewm.html
│   └── styles_gruvbox.css
│
├── docs/                           # Documentation
│   ├── README.md                   # Index de la documentation
│   ├── QUICK_START.md              # Démarrage rapide
│   ├── PACKAGES.md                 # Liste des paquets
│   ├── PREREQUISITES.md            # Prérequis système
│   ├── GLAZEWM_ZEBAR_GUIDE.md      # Guide GlazeWM + Zebar
│   ├── PROJECT_STRUCTURE.md        # Ce fichier
│   └── audit/                      # Revue multi-experts + feuille de route
│
├── logs/                           # Logs d'installation (gitignored)
├── .vscode/                        # Configuration VS Code
│
├── LICENSE                         # Licence MIT
├── SECURITY.md                     # Avertissement conformité + signalement
├── CONTRIBUTING.md                 # Setup contributeur
├── .gitignore
├── .pre-commit-config.yaml         # Hooks (PSScriptAnalyzer)
└── .claude/agents/                 # Équipe de revue multi-experts (outillage)
```

## Fichiers clés

- **`install.ps1`** — point d'entrée, prompts interactifs par catégorie.
- **`uninstall.ps1`** — rollback non destructeur (ne touche ni à `config/` ni à winget).
- **`check.ps1`** — vérifie la présence effective des composants installés.
- **`docs/README.md`** — index de toute la documentation.

## Composants

| Catégorie | Composants |
|-----------|------------|
| Core | winget, Git, GitHub CLI, Windows Terminal, NerdFonts, PowerShell 7, CLI toolbox |
| Desktop | GlazeWM (tiling), Zebar (barre de statut, thème Gruvbox) |
| Linux (opt-in) | WSL2 + Ubuntu, Docker |
| Advanced ⚠️ (opt-in) | Outils susceptibles d'enfreindre une politique IT — voir [SECURITY.md](../SECURITY.md) |

## Workflow

```powershell
.\install.ps1     # Installation interactive (répondre aux prompts Y/N)
.\check.ps1       # Vérifier l'état de l'environnement
.\uninstall.ps1   # Désinstaller les composants
```
