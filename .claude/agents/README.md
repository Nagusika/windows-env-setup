# 🧠 Équipe de revue multi-experts — « Le panel »

Ce dossier définit une **équipe de subagents experts** chargée de réviser ce dépôt
(`windows-env-setup`) sous plusieurs angles indépendants, puis de converger vers un
plan d'action priorisé.

> Objectif produit du dépôt : **permettre à quiconque coincé avec un laptop Windows
> "corpo" verrouillé de retrouver un environnement type Linux réellement utile.**
> Chaque expert doit juger le projet à l'aune de cette promesse.

## Les experts

| Agent | Mandat | Question centrale |
|-------|--------|-------------------|
| [`ps-correctness-engineer`](ps-correctness-engineer.md) | Robustesse PowerShell | « Est-ce que ça marche vraiment, et est-ce ré-exécutable sans casse ? » |
| [`corpo-constraints-realist`](corpo-constraints-realist.md) | Réalisme en environnement verrouillé | « Est-ce que ça tourne sans droits admin / sans winget / sans WSL ? » |
| [`security-compliance-auditor`](security-compliance-auditor.md) | Sécurité & conformité entreprise | « Qu'est-ce qui ferait sonner l'EDR ou virer l'utilisateur ? » |
| [`docs-consistency-editor`](docs-consistency-editor.md) | Cohérence documentaire | « La doc dit-elle la vérité sur le code ? » |
| [`repo-architect`](repo-architect.md) | Architecture, CI, tests | « Est-ce un dépôt maintenable et industrialisé ? » |
| [`devex-portfolio-curator`](devex-portfolio-curator.md) | Portfolio & expérience | « Est-ce un projet GitHub dont on est fier ? » |

## Les règles du panel (protocole)

1. **Indépendance d'abord.** Chaque expert analyse sa dimension *sans* lire les
   conclusions des autres. La diversité des angles est la valeur ; la redondance est du bruit.
2. **Preuve obligatoire.** Toute conclusion cite un fichier + une ligne/extrait. Pas
   d'affirmation sans `chemin:ligne` ou bloc de code reproductible.
3. **Barème de sévérité partagé :**
   - **P0 — Cassé / dangereux** : ne marche pas, détruit des données, ou expose à un risque RH/sécurité.
   - **P1 — Trompe l'utilisateur** : "succès" affiché alors que ça a échoué, promesse non tenue, faille de conformité.
   - **P2 — Qualité / maintenabilité** : dette technique, duplication, dérive doc.
   - **P3 — Polissage / portfolio** : présentation, confort, différenciation.
4. **Remède concret.** Chaque constat fournit un correctif actionnable + un coût
   (`trivial` / `small` / `medium` / `large`), pas seulement un diagnostic.
5. **Vérification adversariale.** Les constats P0/P1 sont re-testés par un sceptique
   dont le but est de *réfuter*. Un constat ne survit que s'il résiste.
6. **Synthèse, pas concaténation.** Le plan final dédoublonne, arbitre les conflits
   entre experts, et ordonne par impact × effort.

## Comment invoquer l'équipe

**Un seul expert** (revue ciblée) :
```
Utilise le subagent `ps-correctness-engineer` pour auditer scripts/install-wsl.ps1
```

**Le panel complet** (orchestration multi-agents) — déclencher avec le mot-clé
`ultracode` puis demander un workflow de revue, ou via la commande `/code-review ultra`.

## Contrat de sortie (chaque expert)

```jsonc
{
  "expert": "corpo-constraints-realist",
  "summary": "Une phrase de verdict global.",
  "findings": [{
    "title": "install.ps1 exige les droits admin et bloque sinon",
    "severity": "P1",
    "files": ["install.ps1:70"],
    "evidence": "throw \"Administrator rights required\"",
    "impact": "Inutilisable sur la cible annoncée (laptop corpo verrouillé).",
    "fix": "Ajouter un palier 'zéro-admin' (Scoop user-scope, apps portables).",
    "effort": "large"
  }]
}
```
