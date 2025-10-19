# Plan de Commits Atomiques

## 🎯 Stratégie

Commits atomiques par fonctionnalité, sans les fichiers de test.

## 📦 Commits Proposés

### Commit 1: Komorebi - Configuration AHK Finale
**Fichiers:**
- `scripts/install-komorebi.ps1` (configuration AHK mise à jour)
- `~/.config/komorebi/komorebi.ahk` (version finale)

**Message:**
```
feat(komorebi): implement smooth navigation with Win key disabled

- Add InstallKeybdHook for complete key interception
- Implement winUsed flag to track Win key usage
- Use ~LWin Up:: to block Start Menu conditionally
- Support holding Win for multiple commands (smooth UX)
- Fix AHK v2 syntax: +#h instead of #+h for Shift+Win
- Add stack shortcuts: Ctrl+Win+H/J/K/L
- Add unstack and cycle stack shortcuts

Technical solution:
- Intercept Win key release with ~LWin Up::
- Track usage with global winUsed flag
- Each hotkey calls MarkWinUsed() to prevent menu
- Allows smooth navigation while blocking Start Menu

Shortcuts added:
- Win+H/J/K/L: Navigate (hold Win for multiple)
- Shift+Win+H/J/K/L: Move window
- Ctrl+Win+H/J/K/L: Stack window
- Win+U: Unstack
- Win+N/Shift+Win+N: Cycle stack
```

### Commit 2: Komorebi - Startup Script
**Fichiers:**
- `START-KOMOREBI.ps1`
- `scripts/fix-komorebi-startup.ps1`

**Message:**
```
feat(komorebi): add startup scripts for easy launch

- Add START-KOMOREBI.ps1 for quick daily startup
- Update fix-komorebi-startup.ps1 with correct AHK path
- Ensure komorebi.ahk is loaded instead of hardcoded paths
- Add status checks and user-friendly output

Usage:
  .\START-KOMOREBI.ps1
```

### Commit 3: Komorebi - Color Themes
**Fichiers:**
- `scripts/install-komorebi.ps1` (fonction Get-ThemeColors déjà présente)
- `docs/KOMOREBI_COLORS.md`

**Message:**
```
feat(komorebi): add color theme documentation

- Document 3 themes: Gruvbox, Tokyo Night, Catppuccin
- Explain border colors: single (focus), stack, monocle, unfocused
- Add color palettes and usage examples
- Include customization guide

Themes provide distinct colors for:
- Normal focus vs stacked focus (visual distinction)
- Monocle/fullscreen mode
- Unfocused windows
```

### Commit 4: Documentation - Komorebi Final Guide
**Fichiers:**
- `docs/KOMOREBI_FINAL.md`
- `docs/README.md` (index)

**Message:**
```
docs(komorebi): add comprehensive final guide

- Complete installation and configuration guide
- Document all keyboard shortcuts
- Explain Win key solution (technical details)
- Add troubleshooting section
- Include smooth navigation workflow

Key features documented:
- Smooth navigation (hold Win)
- Win key menu disabled
- Stack/Move/Navigate shortcuts
- Color themes
```

### Commit 5: Documentation - Project Organization
**Fichiers:**
- `README.md` (mise à jour)
- `PROJECT_STRUCTURE.md`
- `docs/README.md`

**Message:**
```
docs: reorganize and update project documentation

- Update main README with Komorebi quick start
- Add PROJECT_STRUCTURE.md for project overview
- Create docs/README.md as documentation index
- Highlight key features and workflows

Improvements:
- Clear documentation hierarchy
- Easy navigation between guides
- Quick start section for Komorebi
- Usage examples and shortcuts
```

### Commit 6: Scripts - Cleanup Utilities
**Fichiers:**
- `scripts/cleanup-komorebi.ps1`
- `scripts/final-cleanup.ps1`

**Message:**
```
chore: add cleanup scripts for maintenance

- Add cleanup-komorebi.ps1 to remove test files
- Add final-cleanup.ps1 for project-wide cleanup
- Keep only essential configuration files
- Remove temporary and test scripts

Cleanup removes:
- Test AHK files
- Temporary scripts
- Debug files
- Duplicate configurations
```

## 🔄 Ordre d'Exécution

```bash
# 1. Configuration AHK finale
git add scripts/install-komorebi.ps1
git commit -m "feat(komorebi): implement smooth navigation with Win key disabled"

# 2. Scripts de démarrage
git add START-KOMOREBI.ps1 scripts/fix-komorebi-startup.ps1
git commit -m "feat(komorebi): add startup scripts for easy launch"

# 3. Thèmes de couleurs
git add docs/KOMOREBI_COLORS.md
git commit -m "feat(komorebi): add color theme documentation"

# 4. Guide final
git add docs/KOMOREBI_FINAL.md docs/README.md
git commit -m "docs(komorebi): add comprehensive final guide"

# 5. Organisation projet
git add README.md PROJECT_STRUCTURE.md
git commit -m "docs: reorganize and update project documentation"

# 6. Scripts de nettoyage
git add scripts/cleanup-komorebi.ps1 scripts/final-cleanup.ps1
git commit -m "chore: add cleanup scripts for maintenance"
```

## 📝 Notes

### Fichiers Exclus (Tests)
Ces fichiers ne seront PAS committés car ce sont des tests/temporaires:
- `test-*.ahk`
- `komorebi-ultimate.ahk` (remplacé par komorebi.ahk)
- `copy-ahk.ps1`
- `test-ahk-launch.ps1`
- `launch-ahk-debug.bat`

Ils ont déjà été supprimés par `final-cleanup.ps1`.

### Fichiers de Config Utilisateur
Ces fichiers sont dans `~/.config/komorebi/` et ne sont PAS dans le repo:
- `komorebi.json` (généré par install)
- `komorebi.ahk` (généré par install)
- `komorebi-startup.ahk` (généré par install)
- `applications.yaml` (généré par install)

Seuls les **scripts qui génèrent** ces fichiers sont dans le repo.

## ✅ Validation

Avant de committer, vérifier:
- [ ] Pas de fichiers de test
- [ ] Pas de chemins hardcodés
- [ ] Documentation à jour
- [ ] Scripts fonctionnels
- [ ] Messages de commit clairs
- [ ] Commits atomiques (une fonctionnalité = un commit)

## 🎯 Résultat Final

Après ces 6 commits, le repo aura:
- ✅ Configuration Komorebi fonctionnelle
- ✅ Scripts de démarrage
- ✅ Documentation complète
- ✅ Thèmes de couleurs
- ✅ Outils de maintenance
- ✅ Pas de fichiers de test
- ✅ Structure propre et maintenable
