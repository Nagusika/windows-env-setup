# 3 — Améliorations & Propositions (Roadmap)

## 3.1 Principes directeurs (transverses, non négociables)

| Principe | Ce que ça impose concrètement |
|----------|-------------------------------|
| **KISS** | `install.ps1` = un moteur **mince** au-dessus d'un manifeste de données. **Ne PAS** construire la chaîne de fallback multi-backend (winget→scoop→portable) proposée sous l'hypothèse « sans admin » : admin dispo → inutile et complexe. Moins de code, pas plus. |
| **Idempotent** | Relancer `install.ps1` 2 fois = même état, zéro effet de bord. Les codes winget « déjà installé » comptent comme succès ; les configs sont **déployées et convergent** à chaque run ; aucune écriture dans le repo. |
| **Honnêteté** | Jamais de « SUCCESS » sans preuve ; jamais de claim non vérifiable. Le `check.ps1` reflète l'état **réel** du système. |
| **Corpo-safe par défaut** | Le chemin par défaut n'installe **rien** qui puisse faire sonner le SOC ou enfreindre la charte. Le risqué est **opt-in, défaut NON, avec avertissement**. |

## 3.2 Repositionnement (la proposition de valeur honnête)

L'angle « zéro-admin » est séduisant mais **faux ici** (admin requis et disponible).
La vraie USP, défendable et différenciante :

> **windows-env-setup — transforme ton laptop Windows pro (managé) en environnement de
> dev type Linux, de façon reproductible et sans te faire flaguer par ton SOC.**
> Admin-friendly, **corpo-safe par défaut** (les outils à risque sont opt-in et signalés),
> idempotent, entièrement journalisé, désinstallation incluse.

C'est ce qui le distingue de **winutil** (debloat/tweaks, admin lourd) et d'un **repo
dotfiles** (config seule, pas de bootstrap) : ici, **environnement dev + desktop tiling
Gruvbox clé en main, pensé pour ne pas te mettre en faute sur un poste d'entreprise.**

### Architecture en paliers (sélectionnables)
| Tier | Contenu | Défaut | Admin |
|------|---------|--------|-------|
| **Core** | Terminal, NerdFonts, Git, GitHub CLI, PowerShell 7, CLI toolbox (rg, fd, fzf, bat, jq, eza, zoxide, starship) | ✅ OUI | requis (dispo) |
| **Desktop** | GlazeWM + Zebar (tiling + barre Gruvbox) | ✅ OUI | requis |
| **Linux** | WSL2, Docker — avec **détection** virtualisation/Hyper-V + note licence Docker | opt-in | requis + virtualisation |
| **Advanced ⚠️** | Nmap, Wireshark, Process Hacker, RustDesk, Rufus, Ventoy, VeraCrypt, SSHFS — *« may violate IT policy »* | **opt-in, défaut NON, averti** | requis |
| **Bonus** | Zéro-admin portable (Scoop user-scope) — *pour un collègue sans admin* | opt-in | non requis |

> qBittorrent : **retiré** du défaut (risque RH disproportionné vs intérêt sur poste pro).

## 3.3 Jalons

### M0 — Vérité & hygiène *(rapide, surtout trivial/small)*
**But :** le dépôt arrête de mentir. → Voir [02-NETTOYAGE.md](02-NETTOYAGE.md) en entier.
`LICENSE`, liens corrigés, « 100+ »→réel, claim « Safe » reformulé, artefacts de dev
supprimés, `requirements.txt`→`PREREQUISITES.md`, `.gitignore` PowerShell, `SECURITY.md`.

### M1 — Fiabilité & idempotence *(le cœur technique)*
**But :** ce qui dit « SUCCESS » l'est vraiment, et relancer est sûr.
- Créer `Invoke-Native` (vérifie `$LASTEXITCODE`, tolère les codes winget « déjà installé/à jour ») et l'utiliser **après chaque** appel winget/wsl/msiexec. *(P0-1)*
- `#Requires -RunAsAdministrator` + `#Requires -Version 5.1` en tête des scripts privilégiés ; retirer le `throw` runtime. *(P2)*
- Rendre `uninstall.ps1` non destructeur. *(P0-2)*
- **Déployer réellement** `wsl.conf` dans `/etc/wsl.conf` du distro (`… | wsl -u root -e tee /etc/wsl.conf`, LF, sans BOM) + `wsl --terminate`. *(P1-6)*
- Écritures Linux **sans BOM** (`[IO.File]::WriteAllText`) + LF. *(P2)*
- `check.ps1` : baser le verdict sur la présence **réelle** des binaires/Appx (pas sur `config/` local) ; corriger le filtre polices (`*CaskaydiaCove*`). *(P2)*
- Détecter le blocage virtualisation (WSL2/Docker) et **message clair** au lieu d'échec brut. *(P2)*

### M2 — Conformité « corpo-safe par défaut »
**But :** le chemin par défaut ne met jamais l'utilisateur en faute.
- Déplacer tous les outils à risque (cf. tier **Advanced ⚠️**) hors du défaut → catégorie opt-in **défaut NON** précédée d'un avertissement EDR/RH. *(P1-1)*
- Retirer qBittorrent.
- Vérif **signature Authenticode** (et idéalement hash épinglé) avant tout `msiexec`/install d'un binaire téléchargé ; privilégier `wsl --install`/`wsl --update` (canal signé) au MSI en dur. *(P1-2)*
- `SECURITY.md` + avertissement en tête de `PACKAGES.md` (drapeau ⚠️ par paquet sensible).

### M3 — Architecture KISS (données vs code)
**But :** une seule source de vérité, lisible, extensible sans toucher au code.
- `WinEnvSetup.psm1` : `Write-Log`, `Confirm-Action`, `Invoke-Native`, `Initialize-LogDir`, `Test-CommandExists`. Chaque script `Import-Module`. Supprime ~150 lignes dupliquées. *(P2)*
- `manifests/packages.json` (ou yaml) : `{ id, name, category, tier, corpSafe, source }`. `install.ps1` devient un **moteur** générique (charge → filtre par tier → boucle → `Invoke-Native`). *(P2)*
- Petit script qui **génère** `docs/PACKAGES.md` + le compteur du README depuis le manifeste → le « 100+ » ne peut plus diverger.
- `-DryRun` (liste sans agir) + `-Unattended` (réponses défaut explicites). *(P2)*

### M4 — Industrialisation
**But :** un inconnu peut contribuer en confiance.
- `.github/workflows/ci.yml` (windows-latest) : PSScriptAnalyzer `-EnableExit` + `Invoke-Pester -CI` + `pre-commit run --all-files`.
- `tests/*.Tests.ps1` Pester **sans toucher au système** : chaque `config/*.json` parse ; le manifeste charge et chaque `id` est non vide ; `Confirm-Action` rend le bon défaut ; les chemins de scripts référencés existent.
- Gouvernance : `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md` (Contributor Covenant), `.github/ISSUE_TEMPLATE/`, `PULL_REQUEST_TEMPLATE.md`, `CODEOWNERS`.
- SemVer : tag `v1.0.0`, `CHANGELOG.md` (Keep a Changelog), GitHub Release (automatisable via les Conventional Commits déjà en place).

### M5 — Portfolio (la vitrine)
**But :** un recruteur comprend et est séduit en 10 secondes.
- **Visuels** dans `docs/assets/` (le plus gros gain manqué) : `hero.png` (desktop tilé + barre Zebar), `install.gif` (prompts Y/N, <2 Mo via ScreenToGif), `before-after.png`, `zebar-bar.png` annoté, `workspaces.gif`. *(P1-7)*
- **Réécrire le README** dans l'ordre cible : H1 + tagline → badges → **image hero** → paragraphe « Why » → TOC → Quick Start (note admin) → GIF install → Features (sobres) → GlazeWM/Zebar (captures) → Packages → « Why not winutil/dotfiles ? » → How it works (idempotence, dry-run, logs) → Uninstall → FAQ (« faut-il l'admin ? » en tête) → Contributing → License.
- **Une seule langue** (anglais pour l'audience portfolio), emojis ≤ 1 par titre H2.
- Bonus : `bootstrap.ps1` + `irm <raw-url> | iex` (avec avertissement sécurité).

## 3.4 Ordre recommandé & effort

```
M0 (vérité)  ──►  M1 (fiabilité+idempotence)  ──►  M2 (corpo-safe)
   rapide            cœur technique                  conformité
                                                        │
                          M3 (KISS: module+manifeste) ◄─┘
                                   │
                          M4 (CI/tests/gouvernance)
                                   │
                          M5 (portfolio: visuels+README)
```

| Jalon | Effort global | Valeur |
|-------|---------------|--------|
| M0 | S | 🔥 débloque la crédibilité |
| M1 | M | 🔥 rend le produit honnête & ré-exécutable |
| M2 | S–M | 🔥 supprime le risque RH/EDR |
| M3 | M–L | maintenabilité + tue les divergences |
| M4 | M | confiance / contribution |
| M5 | M | impact portfolio |

## 3.5 Quick wins (faisables aujourd'hui, < 1 h chacun)
1. Ajouter `LICENSE` (MIT). *(trivial)*
2. Corriger les liens du README + supprimer les fichiers fantômes. *(small)*
3. Sortir qBittorrent + outils offensifs du défaut. *(small)*
4. Neutraliser `Remove-ConfigurationFiles` et `Uninstall-Winget` dans `uninstall.ps1`. *(small)*
5. Remplacer « 100+ » par le chiffre réel + reformuler « Safe ». *(trivial)*
