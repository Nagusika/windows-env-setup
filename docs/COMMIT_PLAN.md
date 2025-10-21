# Plan de Commits Atomiques

## 🎯 Stratégie

Commits atomiques par fonctionnalité, sans les fichiers de test.

## 📦 Commits Proposés

### Commit 1: Core Installation Scripts
**Fichiers:**
- `install.ps1`
- `uninstall.ps1`
- `scripts/install-*.ps1`

**Message:**
```
feat: add core installation scripts

- Add main interactive installation script
- Add individual component installation scripts
- Add uninstallation script
- Include logging and error handling
```

### Commit 2: Configuration Files
**Fichiers:**
- `config/wsl.conf`
- `config/terminal-settings.json`
- `config/winget-settings.json`

**Message:**
```
feat: add configuration files for components

- Add WSL configuration
- Add Windows Terminal settings
- Add winget configuration
```

### Commit 3: Documentation
**Fichiers:**
- `README.md`
- `docs/*.md`

**Message:**
```
docs: add comprehensive project documentation

- Add main README with quick start
- Add package documentation
- Add project structure guide
- Add quick start guide
```

## 🔄 Ordre d'Exécution

```bash
# 1. Scripts d'installation
git add install.ps1 uninstall.ps1 scripts/
git commit -m "feat: add core installation scripts"

# 2. Fichiers de configuration
git add config/
git commit -m "feat: add configuration files for components"

# 3. Documentation
git add README.md docs/
git commit -m "docs: add comprehensive project documentation"
```

## ✅ Validation

Avant de committer, vérifier:
- [ ] Pas de fichiers de test
- [ ] Pas de chemins hardcodés
- [ ] Documentation à jour
- [ ] Scripts fonctionnels
- [ ] Messages de commit clairs
- [ ] Commits atomiques (une fonctionnalité = un commit)

## 🎯 Résultat Final

Après ces commits, le repo aura:
- ✅ Scripts d'installation fonctionnels
- ✅ Documentation complète
- ✅ Fichiers de configuration
- ✅ Pas de fichiers de test
- ✅ Structure propre et maintenable
