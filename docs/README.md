# Documentation - Windows Environment Setup

## 📚 Documentation Essentielle

### 🚀 Démarrage
- **[QUICK_START.md](QUICK_START.md)** - Guide de démarrage rapide (5 min)

### 🪟 Komorebi - Tiling Window Manager
- **[KOMOREBI_FINAL.md](KOMOREBI_FINAL.md)** ⭐ - **Guide Complet**
  - Installation et configuration
  - Raccourcis clavier
  - Solution Win key (smooth navigation)
  - Troubleshooting
  
- **[KOMOREBI_SHORTCUTS.md](KOMOREBI_SHORTCUTS.md)** - Liste des raccourcis
- **[KOMOREBI_COLORS.md](KOMOREBI_COLORS.md)** - Thèmes de couleurs

### 📦 Packages
- **[PACKAGES.md](PACKAGES.md)** - Liste des 100+ packages FOSS

### 🔧 Projet
- **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** - Structure du projet
- **[COMMIT_PLAN.md](COMMIT_PLAN.md)** - Plan de commits atomiques

### 📁 Archive
Documentation détaillée archivée dans **[archive/](archive/)** (11 guides)

## 🎯 Par Cas d'Usage

### Je veux installer Komorebi
→ Lisez **[KOMOREBI_FINAL.md](KOMOREBI_FINAL.md)**

### Je veux comprendre les raccourcis
→ Lisez **[KOMOREBI_SHORTCUTS.md](KOMOREBI_SHORTCUTS.md)**

### Komorebi ne démarre pas
→ Lisez **[KOMOREBI_STARTUP_FIX.md](KOMOREBI_STARTUP_FIX.md)**

### Je veux changer les couleurs
→ Lisez **[KOMOREBI_COLORS.md](KOMOREBI_COLORS.md)**

### J'ai plusieurs écrans
→ Lisez **[KOMOREBI_MULTI_MONITOR.md](KOMOREBI_MULTI_MONITOR.md)**

### Le menu Windows s'ouvre encore
→ Lisez **[KOMOREBI_WINDOWS_KEY.md](KOMOREBI_WINDOWS_KEY.md)**

## 🔧 Structure du Projet

```
windows-env-setup/
├── START-KOMOREBI.ps1          # 🚀 Démarrage rapide Komorebi
├── install.ps1                 # 📦 Installation complète
├── uninstall.ps1               # 🗑️ Désinstallation
├── scripts/
│   ├── install-komorebi.ps1    # Installation Komorebi
│   ├── fix-komorebi-startup.ps1 # Fix démarrage auto
│   ├── cleanup-komorebi.ps1    # Nettoyage
│   └── final-cleanup.ps1       # Nettoyage final
├── docs/                       # 📚 Documentation (ce dossier)
└── config/                     # ⚙️ Configurations
```

## 📝 Notes

- Les fichiers marqués ⭐ sont les plus importants
- Commencez par **KOMOREBI_FINAL.md** pour une installation complète
- La documentation est organisée par thème et cas d'usage
- Tous les guides sont à jour avec la configuration finale qui fonctionne

## 🆘 Support

Si vous rencontrez un problème:
1. Consultez **[KOMOREBI_STARTUP_FIX.md](KOMOREBI_STARTUP_FIX.md)**
2. Vérifiez les raccourcis dans **[KOMOREBI_SHORTCUTS.md](KOMOREBI_SHORTCUTS.md)**
3. Relancez `.\START-KOMOREBI.ps1`

## 🎨 Personnalisation

- **Couleurs**: [KOMOREBI_COLORS.md](KOMOREBI_COLORS.md)
- **Raccourcis**: Éditez `~/.config/komorebi/komorebi.ahk`
- **Workspaces**: Éditez `~/.config/komorebi/komorebi.json`
