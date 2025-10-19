# Komorebi - Configuration Finale

## ✅ Installation Complète

Komorebi est maintenant installé et configuré avec une navigation fluide et le menu Windows désactivé.

## 🚀 Démarrage Rapide

### Démarrer Komorebi
```powershell
.\START-KOMOREBI.ps1
```

### Arrêter Komorebi
```powershell
Stop-Process -Name komorebi,autohotkey,zebar -Force
```

## ⌨️ Raccourcis Clavier

### Navigation (maintenir Win pour enchainer)
- `Win+H/J/K/L` ou `Win+Flèches` - Naviguer entre les fenêtres
- Vous pouvez **maintenir Win** et taper H/J/K/L plusieurs fois!

### Déplacer Fenêtres
- `Shift+Win+H/J/K/L` - Déplacer la fenêtre active
- `Shift+Win+Flèches` - Déplacer avec les flèches

### Workspaces
- `Win+1/2/3/4/5` - Changer de workspace
- `Shift+Win+1/2/3/4/5` - Déplacer fenêtre vers workspace

### Actions
- `Win+Enter` - Ouvrir terminal
- `Win+Space` - Ouvrir Flow Launcher
- `Win+Q` - Fermer fenêtre
- `Win+T` - Toggle float (fenêtre flottante)
- `Win+F` - Toggle fullscreen
- `Shift+Win+C` - Recharger configuration AHK

### Raccourcis Windows Préservés
- `Win+E` - Explorateur
- `Win+R` - Paramètres
- `Win+D` - Afficher bureau
- `Win+Tab` - Vue des tâches

## 🔧 Configuration

### Fichiers Principaux
- `~/.config/komorebi/komorebi.json` - Configuration Komorebi
- `~/.config/komorebi/komorebi.ahk` - Raccourcis clavier
- `~/.config/komorebi/komorebi-startup.ahk` - Script de démarrage
- `~/.config/komorebi/applications.yaml` - Règles d'applications

### Thèmes Disponibles
- **Tokyo Night** (actuel) - Cool, moderne
- **Gruvbox** - Warm, rétro
- **Catppuccin** - Pastel, élégant

Pour changer de thème:
```powershell
.\scripts\install-komorebi.ps1 -Theme gruvbox -Force
```

## 🎯 Fonctionnalités Clés

### ✅ Menu Windows Désactivé
- `Win` seul ne fait rien
- Toutes les combinaisons `Win+X` fonctionnent
- Navigation fluide en maintenant Win

### ✅ Navigation Smooth
- Maintenez `Win` et tapez `H`, `J`, `K`, `L` plusieurs fois
- Pas besoin de relâcher Win entre chaque commande
- UX fluide et rapide

### ✅ Tiling Automatique
- Les fenêtres se placent automatiquement
- Layouts: BSP, Columns, Rows, etc.
- Bordures colorées selon le focus

## 📁 Structure du Projet

```
windows-env-setup/
├── START-KOMOREBI.ps1          # Démarrage rapide
├── scripts/
│   ├── install-komorebi.ps1    # Installation complète
│   ├── fix-komorebi-startup.ps1 # Fix démarrage auto
│   └── cleanup-komorebi.ps1    # Nettoyage
└── docs/
    ├── KOMOREBI_FINAL.md       # Ce fichier
    ├── KOMOREBI_GUIDE.md       # Guide complet
    └── KOMOREBI_SHORTCUTS.md   # Liste des raccourcis
```

## 🔄 Démarrage Automatique

Pour que Komorebi démarre au login Windows:

```powershell
.\scripts\fix-komorebi-startup.ps1
```

Cela crée un raccourci dans:
```
%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Komorebi.lnk
```

## 🐛 Troubleshooting

### Komorebi ne démarre pas
```powershell
# Vérifier si Komorebi est installé
komorebic --version

# Démarrer manuellement
komorebic start

# Vérifier les processus
Get-Process komorebi,autohotkey
```

### Les raccourcis ne fonctionnent pas
```powershell
# Arrêter tous les processus AHK
Stop-Process -Name autohotkey -Force

# Relancer
.\START-KOMOREBI.ps1
```

### Menu Windows s'ouvre encore
Vérifiez qu'un seul processus AutoHotkey tourne:
```powershell
Get-Process autohotkey
```

Si plusieurs processus, arrêtez-les tous et relancez.

## 📝 Notes Techniques

### Solution Win Key
La configuration utilise une approche innovante pour désactiver le menu Windows:

1. **Interception du relâchement**: `~LWin Up::` intercepte quand Win est relâché
2. **Flag global**: `winUsed` track si Win a été utilisé avec une touche
3. **Blocage conditionnel**: Si `winUsed == false`, le menu est bloqué
4. **Smooth navigation**: Les hotkeys `#h::` permettent de maintenir Win

Cette approche permet:
- ✅ Navigation fluide (maintenir Win)
- ✅ Pas de menu Start
- ✅ Toutes les combinaisons Win+X fonctionnent
- ✅ Compatible AHK v2

### Syntaxe AHK v2
- `#h::` = Win+H
- `+#h::` = Shift+Win+H (Shift d'abord!)
- `^#h::` = Ctrl+Win+H
- `!#h::` = Alt+Win+H

**Important**: En AHK v2, l'ordre des modificateurs compte!
- ✅ `+#h` fonctionne
- ❌ `#+h` ne fonctionne pas

## 🎉 Résultat Final

Vous avez maintenant:
- ✅ Komorebi qui tile automatiquement
- ✅ Navigation fluide avec Win maintenu
- ✅ Menu Windows désactivé
- ✅ Tous les raccourcis fonctionnels
- ✅ Démarrage automatique configuré
- ✅ Configuration propre et maintenable

**Profitez de votre nouveau window manager!** 🚀
