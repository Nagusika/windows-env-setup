# 🔎 Audit & Plan — windows-env-setup

Revue multi-experts du dépôt (6 experts, 57 constats vérifiés par lecture +
vérification adversariale des constats critiques), puis plan d'action priorisé.

> **Cadre de la revue (corrigé en cours de route) :**
> - 🎯 Cible réelle : **laptop Windows d'entreprise (managé, EDR/GPO) MAIS avec droits admin disponibles.**
> - 🧭 Principes directeurs imposés : **KISS** (rester simple) et **idempotent** (ré-exécutable sans casse).

## Les 3 documents du plan

| # | Document | Réponds à |
|---|----------|-----------|
| 1 | [01-ANALYSE.md](01-ANALYSE.md) | **Analyse** — verdict, constats recalibrés, hiérarchie P0→P3 |
| 2 | [02-NETTOYAGE.md](02-NETTOYAGE.md) | **Nettoyage** — quoi supprimer / corriger, fichier par fichier |
| 3 | [03-AMELIORATIONS-ROADMAP.md](03-AMELIORATIONS-ROADMAP.md) | **Améliorations + Propositions** — repositionnement, jalons M0→M5 |

## L'équipe qui a produit cette revue

Définie dans [.claude/agents/](../../.claude/agents/) — réutilisable pour les prochaines revues :
`ps-correctness-engineer`, `corpo-constraints-realist`, `security-compliance-auditor`,
`docs-consistency-editor`, `repo-architect`, `devex-portfolio-curator`.

## Verdict en une phrase

> Bonne idée, bonne matière (GlazeWM/Zebar, CLI toolbox), mais **trois mensonges à
> corriger d'urgence** : le code ment (succès affiché sur échec), la doc ment (liens
> cassés, « 100+ », licence MIT sans fichier), et le défaut par défaut **expose
> l'utilisateur à un risque RH/EDR** (qBittorrent, Nmap, Wireshark… installés sans
> avertissement sur une machine pro). Le reste est de la dette saine à rembourser.
