# 4 — Analyse & refonte de la config GlazeWM + raccourcis

Revue complète de [config/glazewm-config.yaml](../../config/glazewm-config.yaml) (et de
son intégration Zebar / du guide). Schéma vérifié contre la config de référence
officielle GlazeWM v3.

> Sources schéma : [sample-config.yaml officiel](https://raw.githubusercontent.com/glzr-io/glazewm/main/resources/assets/sample-config.yaml),
> [issue #78 « monocle »](https://github.com/glzr-io/glazewm/issues/78), [glazewm.com](https://glazewm.com/).

## 4.1 Bugs de correctness (schéma invalide)

| # | Constat | Preuve | Sévérité |
|---|---------|--------|----------|
| G-1 | **`hide_method` et `show_all_in_taskbar` sont indentés sous `cursor_jump:`** (4 espaces) alors qu'ils sont des **enfants directs de `general:`**. GlazeWM les ignore (ou erreur). | Schéma officiel : `cursor_jump` n'accepte que `enabled` + `trigger` ; `hide_method`/`show_all_in_taskbar` sont frères de `cursor_jump`. Config repo : lignes 28 & 34 à 4 espaces. | **P1** |
| G-2 | **`hide_method: 'hide'`** = méthode héritée (v3.5−), instable avec certaines apps. | Le schéma recommande `'cloak'` (v3.6+). | P2 |
| G-3 | **`layout: "monocle"`** sur les workspaces 4 et 5 = **propriété inexistante** pour un workspace GlazeWM v3 → ignorée. | Les workspaces n'acceptent que `name`, `display_name`, `keep_alive`, `bind_to_monitor`. Le monocle n'est pas supporté (issue #78 ouverte, jamais livrée). | P2 |
| G-4 | **Typo regex `[wW]indwos[Tt]erminal`** ("windwos") → Windows Terminal n'est jamais matché par cette alternative ; le process réel est `WindowsTerminal`. | `config:211`. | P2 |
| G-5 | **Commentaire `inner_gap: '5px'.E`** (typo), commentaires de blocs résiduels. | `config:40`. | P3 |

## 4.2 Ergonomie des raccourcis (le cœur de la demande)

### Problème central : la grappe HJKL est **incohérente sous Shift**
| Touche | Action actuelle | Problème |
|--------|-----------------|----------|
| `alt+shift+h` / `l` | **déplacer le workspace** vers le moniteur gauche/droite | h/l ne déplacent PAS la fenêtre… |
| `alt+shift+j` / `k` | **déplacer la fenêtre** bas/haut | …mais j/k si. Deux catégories d'action dans la même grappe. |
| déplacer fenêtre ←/→ | **uniquement** `alt+shift+flèches` | aucune touche lettre pour bouger la fenêtre horizontalement. |

→ Un réflexe vim « `alt+shift+h` = bouger la fenêtre à gauche » **déplace en réalité tout le workspace** vers un autre écran. Incohérent et surprenant.

### Autres frictions
- **Resize `alt+u/i/o/p`** : grappe non mnémonique et redondante avec le **mode resize** (`alt+r` → hjkl), qui est la voie idiomatique GlazeWM. Encombre l'espace de touches.
- **`alt+shift+z` / `alt+shift+s`** pour déplacer le workspace haut/bas : choix arbitraires (z/s).
- **`move-workspace` mélangé** avec move-window dans la grappe Shift (cf. ci-dessus).

### Schéma proposé (cohérent, sans conflit, vim-first)
| Intention | Raccourci proposé | Avant |
|-----------|-------------------|-------|
| Focus fenêtre | `alt + h/j/k/l` (+ flèches) | inchangé |
| **Déplacer la fenêtre** | `alt+shift + h/j/k/l` (+ flèches) — **les 4 directions** | h/l étaient pris par move-workspace |
| **Déplacer le workspace** vers un écran | `alt+ctrl + h/j/k/l` (+ flèches) | était `alt+shift+h/l` + `z/s` |
| Focus workspace 1-9 | `alt + 1..9` | inchangé |
| Déplacer fenêtre → workspace | `alt+shift + 1..9` | inchangé |
| Resize | **mode** `alt+r` puis `h/j/k/l` | suppression du doublon `alt+u/i/o/p` |

Bénéfices : Shift = « j'agis sur la **fenêtre** », Ctrl = « j'agis sur le **workspace/écran** », grappe HJKL homogène dans les deux cas, plus aucune touche lettre orpheline.

## 4.3 Window rules

| # | Constat | Correctif |
|---|---------|-----------|
| W-1 | Terminal jamais matché (typo `windwos`) | `regex: "WindowsTerminal\|wt\|cmd"` |
| W-2 | Le guide annonce « **Cursor** → ws4 » mais la regex `[Cc]ode` ne matche pas Cursor | `regex: "Code\|Cursor"` |
| W-3 | Regex larges (`explorer`, `[Cc]ode`) — acceptables, à surveiller | documenter |

## 4.4 Portabilité multi-écrans (enjeu pour la cible « laptop corpo »)

La config **câble 9 workspaces sur 3 moniteurs** (`bind_to_monitor: 0/1/2`). Sur un poste
corpo typique (1 écran, parfois 1 dock), les workspaces 4-9 pointent vers des moniteurs
absents : GlazeWM les rabat sur l'écran primaire — **fonctionnel mais l'organisation
voulue s'effondre** (tout s'empile sur un écran).

**Recommandation** : garder l'intention multi-écrans de l'auteur, mais **documenter
explicitement** comment adapter à 1/2 écrans (commenter les `bind_to_monitor`, ou les
mettre tous à `0`). Ajouté en commentaire en tête du bloc `workspaces` + dans le guide.

## 4.5 Dérive doc ↔ config (guide)

- Guide : « Cursor → ws4 » non implémenté (cf. W-2).
- Guide : « `alt+shift+flèches` = déplacer la fenêtre » **et** « `alt+shift+H/L` = déplacer le workspace » → modèle mental contradictoire (flèches ≠ hjkl). Résolu par le nouveau schéma.
- Non documentés : `alt+v` (sens de tuilage), `alt+space` (cycle focus), `alt+a/s/d`, déplacement de workspace, mode resize détaillé.

## 4.6 Plan d'application
1. Réécrire `glazewm-config.yaml` : G-1…G-5 + nouveau schéma de raccourcis + W-1/W-2 + commentaire multi-écrans.
2. Mettre le guide à jour (tableau de raccourcis aligné, note multi-écrans, Cursor).
3. Valider le YAML.

> Note : le changement de raccourcis modifie la mémoire musculaire (`alt+shift+h/l`
> déplace désormais la **fenêtre**, le déplacement de **workspace** passe sur `alt+ctrl`).
> C'est volontaire et documenté.
