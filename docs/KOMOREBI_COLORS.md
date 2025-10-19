# Komorebi - Palettes de Couleurs

## 🎨 Thèmes Disponibles

### Tokyo Night (Actuel)
Thème moderne et cool avec des bleus/violets

**Bordures:**
- **Focus Normal** (`single`): `#7aa2f7` - Bleu vif
- **Focus Stacked** (`stack`): `#bb9af7` - Violet/Mauve
- **Monocle/Fullscreen** (`monocle`): `#9ece6a` - Vert
- **Unfocused**: `#3b4261` - Gris bleuté foncé

**Stackbar:**
- Texte focus: `#c0caf5` - Blanc bleuté
- Texte unfocus: `#565f89` - Gris
- Background: `#1a1b26` - Noir bleuté

### Gruvbox
Thème warm et rétro avec des tons chauds

**Bordures:**
- **Focus Normal** (`single`): `#d79921` - Jaune/Or
- **Focus Stacked** (`stack`): `#b16286` - Violet/Magenta
- **Monocle/Fullscreen** (`monocle`): `#689d6a` - Vert aqua
- **Unfocused**: `#504945` - Gris chaud

**Stackbar:**
- Texte focus: `#ebdbb2` - Beige clair
- Texte unfocus: `#928374` - Gris chaud
- Background: `#282828` - Noir chaud

### Catppuccin
Thème pastel et élégant

**Bordures:**
- **Focus Normal** (`single`): `#89b4fa` - Bleu pastel
- **Focus Stacked** (`stack`): `#cba6f7` - Violet pastel
- **Monocle/Fullscreen** (`monocle`): `#a6e3a1` - Vert pastel
- **Unfocused**: `#45475a` - Gris foncé

**Stackbar:**
- Texte focus: `#cdd6f4` - Blanc pastel
- Texte unfocus: `#6c7086` - Gris moyen
- Background: `#1e1e2e` - Noir doux

## 🔧 Changer de Thème

```powershell
# Gruvbox
.\scripts\install-komorebi.ps1 -Theme gruvbox -Force

# Tokyo Night
.\scripts\install-komorebi.ps1 -Theme tokyonight -Force

# Catppuccin
.\scripts\install-komorebi.ps1 -Theme catppuccin -Force
```

## 🎯 Signification des Couleurs

### Border Colors

**`single`** - Focus Normal
- Fenêtre unique avec le focus
- C'est la couleur que vous verrez le plus souvent
- Doit être bien visible et agréable

**`stack`** - Focus Stacked
- Fenêtre stackée (empilée) avec le focus
- Différente de `single` pour identifier visuellement le stack
- Généralement une couleur complémentaire (violet si bleu, etc.)

**`monocle`** - Fullscreen/Monocle
- Fenêtre en mode fullscreen (Win+F)
- Couleur distinctive pour indiquer le mode spécial
- Souvent vert pour "go" / "actif"

**`unfocused`** - Sans Focus
- Toutes les fenêtres qui n'ont pas le focus
- Couleur discrète pour ne pas distraire
- Gris foncé généralement

### Stackbar Colors

**`focused_text`** - Texte de l'onglet actif
- Texte bien visible
- Contraste élevé avec le background

**`unfocused_text`** - Texte des onglets inactifs
- Texte plus discret
- Gris moyen

**`background`** - Fond de la stackbar
- Couleur de fond des onglets
- Généralement proche du fond de votre terminal/IDE

## 🎨 Personnalisation

Pour créer votre propre palette, éditez:
```
~/.config/komorebi/komorebi.json
```

Puis rechargez:
```powershell
komorebic stop
komorebic start
```

### Exemple de Palette Custom

```json
"border_colours": {
  "single": "#ff6b6b",      // Rouge vif
  "stack": "#4ecdc4",       // Cyan
  "monocle": "#ffe66d",     // Jaune
  "unfocused": "#2d3436"    // Gris foncé
}
```

## 🌈 Conseils de Design

1. **Contraste**: Focus doit être bien visible vs unfocused
2. **Harmonie**: Utilisez des couleurs complémentaires
3. **Cohérence**: Alignez avec votre terminal/IDE
4. **Accessibilité**: Évitez rouge/vert pur (daltonisme)

## 📊 Comparaison Visuelle

```
Tokyo Night:  🔵 Bleu → 🟣 Violet → 🟢 Vert
Gruvbox:      🟡 Or   → 🟣 Magenta → 🟢 Aqua
Catppuccin:   🔵 Bleu → 🟣 Violet → 🟢 Vert (pastel)
```

## 🔄 Recharger les Couleurs

Après modification manuelle:

```powershell
# Méthode 1: Restart Komorebi
komorebic stop
Start-Sleep -Seconds 2
komorebic start

# Méthode 2: Reload config
komorebic configuration "$env:USERPROFILE\.config\komorebi\komorebi.json"

# Méthode 3: Script complet
.\START-KOMOREBI.ps1
```

## 💡 Astuce

Les couleurs de bordure sont visibles même quand les fenêtres sont maximisées (avec `border_offset: -1`), ce qui permet de toujours voir quelle fenêtre a le focus!
