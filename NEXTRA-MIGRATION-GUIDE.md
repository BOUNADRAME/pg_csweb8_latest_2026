# CSWeb Community Platform - Migration vers Nextra Documentation

## 🎯 Objectif

Migrer la documentation CSWeb Community Platform (21 fichiers Markdown dispersés) vers une documentation moderne construite avec **Nextra** (Next.js + MDX).

**Résultat attendu :** Documentation niveau Next.js/Tailwind avec recherche full-text, dark mode, mobile responsive.

---

## ✅ Phase 1+2 COMPLÉTÉES (7h30)

### Ce qui a été implémenté

#### 1. Setup Nextra Complet
- ✅ Next.js 14.2.35 + Nextra 2.13.4
- ✅ Configuration TypeScript
- ✅ Theme Nextra personnalisé (logo, navigation, footer)
- ✅ i18n ready (FR/EN)
- ✅ 407 packages NPM installés

#### 2. Composants React Custom
- ✅ **Callout** - Boxes stylisés (Info/Warning/Error/Success)
- ✅ **Tabs** - Multi-language code examples
- ✅ **CodeBlock** - Code blocks avec copy button

#### 3. Navigation Multi-niveaux
- ✅ 14 fichiers `_meta.json` pour navigation automatique
- ✅ 3 sections principales (Getting Started, Guides, Reference)
- ✅ 15 sous-sections organisées

#### 4. Pages Critiques (5 pages, 2,550 lignes)

**Landing Page :**
- Hero section avec gradient
- Features grid (4 cards)
- Stats (255+ pages, 3 SGBD, etc.)
- Cas d'usage (Dev, INS, Recherche)

**Getting Started (5 pages) :**
1. **Bienvenue** (400 lignes) - Architecture overview, CSWeb vs Vanilla
2. **Installation** (500 lignes) - Consolidation de 3 fichiers sources, Docker setup
3. **Premier Breakout** (450 lignes) - Tutorial step-by-step complet
4. **Vérification** (500 lignes) - Checklist 12 catégories
5. **Prochaines Étapes** (550 lignes) - 3 parcours, liens vers guides

#### 5. Build Réussi
- ✅ `npm run build` sans erreurs
- ✅ 24 pages statiques générées
- ✅ Optimisation production (85.2 kB JS partagé)

---

## 📁 Structure Actuelle

```
docs-nextra/
├── pages/
│   ├── index.mdx                  ✅ COMPLÉTÉ
│   ├── getting-started/
│   │   ├── index.mdx              ✅ COMPLÉTÉ
│   │   ├── installation.mdx       ✅ COMPLÉTÉ
│   │   ├── first-breakout.mdx     ✅ COMPLÉTÉ
│   │   ├── verify.mdx             ✅ COMPLÉTÉ
│   │   └── next-steps.mdx         ✅ COMPLÉTÉ
│   ├── guides/
│   │   ├── breakout/              🚧 À FAIRE (3 pages)
│   │   ├── database/              🚧 À FAIRE (5 pages)
│   │   ├── admin/                 🚧 À FAIRE (5 pages)
│   │   ├── architecture/          🚧 À FAIRE (4 pages)
│   │   └── deployment/            🚧 À FAIRE (5 pages)
│   └── reference/
│       ├── api/                   🚧 À FAIRE (4 pages)
│       ├── cli/                   🚧 À FAIRE (3 pages)
│       ├── config/                🚧 À FAIRE (3 pages)
│       ├── troubleshooting/       🚧 À FAIRE (3 pages - PRIORITÉ)
│       └── resources/             🚧 À FAIRE (3 pages)
├── components/
│   ├── Callout.tsx                ✅ COMPLÉTÉ
│   ├── Tabs.tsx                   ✅ COMPLÉTÉ
│   └── CodeBlock.tsx              ✅ COMPLÉTÉ
├── public/images/                 🚧 À REMPLIR
├── theme.config.jsx               ✅ COMPLÉTÉ
├── next.config.js                 ✅ COMPLÉTÉ
├── package.json                   ✅ COMPLÉTÉ
└── README.md                      ✅ COMPLÉTÉ
```

---

## 🚀 Démarrage Rapide

### Installation

```bash
cd docs-nextra
npm install
```

### Développement

```bash
# Option 1 : Script automatique
./start-dev.sh

# Option 2 : Manuel
npm run dev
```

Ouvrir http://localhost:3000

### Build Production

```bash
npm run build
npm start
```

---

## 📋 Phase 3 : Guides & Reference (12-16h)

### Priorités

#### 1. Troubleshooting (4h - CRITIQUE)

**Fichiers à créer :**
- `reference/troubleshooting/common-issues.mdx` - 50+ problèmes courants
  - Port conflicts (8080, 5432, 3306)
  - Database connection refused
  - Driver not found (pdo_pgsql, sqlsrv)
  - Permission denied (Docker volumes)
  - Breakout failures
  - OAuth authentication errors

- `reference/troubleshooting/faq.mdx` - 30+ FAQs
  - CSWeb Community vs vanilla ?
  - Quel DB choisir (PostgreSQL/MySQL/SQL Server) ?
  - Migration local → remote ?
  - Production-ready ?
  - Coût hébergement cloud ?

- `reference/troubleshooting/errors.mdx` - Référence codes d'erreur

#### 2. Guides Breakout (3h)

**Fichiers sources :** `docs/MIGRATION-BREAKOUT-SELECTIF.md` (1390 lignes)

**Migration :**
- `guides/breakout/selective.mdx` - Guide utilisateur breakout sélectif
- `guides/breakout/scheduled.mdx` - Scheduler jobs (NOUVEAU)
- `guides/breakout/monitoring.mdx` - Logs temps réel (NOUVEAU)

**Stratégie :** Diviser le fichier source en 3 pages focalisées

#### 3. Guides Database (4h)

**Fichiers sources :** `docs/CONFIGURATION-MULTI-DATABASE.md` (1097 lignes)

**Migration :**
- `guides/database/multi-db.mdx` - Vue d'ensemble Multi-DB
- `guides/database/postgresql.mdx` - Configuration PostgreSQL
- `guides/database/mysql.mdx` - Configuration MySQL
- `guides/database/sqlserver.mdx` - Configuration SQL Server
- `guides/database/migration.mdx` - Migration entre SGBD (NOUVEAU)

**Stratégie :** Séparer par SGBD + guide migration

#### 4. API Reference (3h)

**Fichiers sources :**
- `docs/CSWEB-OAUTH-AUTHENTICATION.md` (1019 lignes)
- `docs/WEBHOOKS-INTEGRATION.md` (1195 lignes)

**Migration :**
- `reference/api/oauth.mdx` - OAuth2 Authentication
- `reference/api/dictionaries.mdx` - Dictionaries API (NOUVEAU)
- `reference/api/breakout.mdx` - Breakout API (NOUVEAU)
- `reference/api/webhooks.mdx` - Webhooks API

**Stratégie :** Séparer parties guide vs API reference

---

## 📝 Template de Migration

### Structure Page MDX

```mdx
---
title: Titre de la Page
description: Description courte pour SEO (max 160 caractères)
---

import { Callout } from '../../components/Callout'
import { Tabs } from '../../components/Tabs'

# Titre Principal

Introduction courte (1-2 paragraphes)

<Callout type="info">
  Note importante pour orienter le lecteur
</Callout>

---

## Section 1

Contenu...

### Sous-section 1.1

Contenu avec exemples de code :

```bash
# Commande bash
docker-compose up -d
```

<Callout type="warning">
  Attention : Point important à noter
</Callout>

---

## Section 2

<Tabs items={['PostgreSQL', 'MySQL', 'SQL Server']}>
  <div>
    ```sql
    -- PostgreSQL
    SELECT * FROM table;
    ```
  </div>
  <div>
    ```sql
    -- MySQL
    SELECT * FROM table;
    ```
  </div>
  <div>
    ```sql
    -- SQL Server
    SELECT * FROM table;
    ```
  </div>
</Tabs>

---

## Prochaines Étapes

- [Lien vers guide suivant](/guides/...)
- [Référence API](/reference/api/...)

<Callout type="success">
  Message de succès pour conclure
</Callout>
```

---

## 🎨 Conventions

### Callouts

```mdx
<Callout type="info">Information générale</Callout>
<Callout type="warning">Attention, point important</Callout>
<Callout type="error">CRITIQUE - Action requise</Callout>
<Callout type="success">Succès ou félicitations</Callout>
```

### Tabs

```mdx
<Tabs items={['Option 1', 'Option 2', 'Option 3']}>
  <div>Contenu option 1</div>
  <div>Contenu option 2</div>
  <div>Contenu option 3</div>
</Tabs>
```

### Code Blocks

```mdx
\```bash
# Commande shell
docker exec -it csweb_app bash
\```

\```sql
-- Requête SQL
SELECT * FROM table;
\```

\```json
{
  "config": "value"
}
\```
```

---

## 📦 Déploiement Vercel

### Étapes

1. **Connecter Repo à Vercel**
   - https://vercel.com/new
   - Import `BOUNADRAME/pg_csweb8_latest_2026`

2. **Configuration Build**
   ```
   Framework Preset: Next.js
   Root Directory: docs-nextra
   Build Command: npm run build
   Output Directory: .next
   ```

3. **Custom Domain**
   - Ajouter `docs.csweb-community.org`

4. **Deploy**
   - Auto-deploy sur push vers `master`
   - Preview deployments sur chaque PR

**URL Preview :** https://csweb-community-docs.vercel.app

---

## ✅ Checklist Vérification

### Phase 1+2 (COMPLÉTÉ)
- ✅ Setup Nextra (Next.js + TypeScript + i18n)
- ✅ Composants React (Callout, Tabs, CodeBlock)
- ✅ Navigation multi-niveaux (14 _meta.json)
- ✅ Landing page (index.mdx)
- ✅ Getting Started (5 pages, 2,550 lignes)
- ✅ Build production réussi (24 pages statiques)
- ✅ README complet avec guidelines

### Phase 3 (À FAIRE)
- [ ] Troubleshooting (3 pages - PRIORITÉ)
- [ ] Guides Breakout (3 pages)
- [ ] Guides Database (5 pages)
- [ ] Guides Admin (5 pages)
- [ ] Guides Architecture (4 pages)
- [ ] Guides Deployment (5 pages)
- [ ] API Reference (4 pages)
- [ ] CLI Reference (3 pages)
- [ ] Config Reference (3 pages)
- [ ] Resources (3 pages)

### Phase 4 (À FAIRE)
- [ ] Vérifier liens internes (150+ liens)
- [ ] Tester recherche full-text
- [ ] Vérifier dark mode
- [ ] Mobile responsive (iOS/Android)
- [ ] Proofreading français
- [ ] Tester code snippets (50+)
- [ ] Deploy to Vercel
- [ ] Custom domain
- [ ] Redirects (.md → new paths)
- [ ] Analytics (Vercel Analytics)

---

## 📊 Mapping Fichiers

### Fichiers Sources → Pages Nextra

| Fichier Actuel | Lignes | Pages Nextra Cibles | Status |
|----------------|--------|---------------------|--------|
| `QUICK-START.md` | 411 | `getting-started/installation.mdx` | ✅ CONSOLIDÉ |
| `GETTING-STARTED.md` | 536 | `getting-started/index.mdx` + `installation.mdx` | ✅ DIVISÉ |
| `ARCHITECTURE-FLEXIBLE.md` | 730 | `guides/architecture/flexible.mdx`<br>`guides/architecture/local-vs-remote.mdx`<br>`guides/deployment/remote.mdx` | 🚧 À FAIRE |
| `CONFIGURATION-MULTI-DATABASE.md` | 1097 | `guides/database/postgresql.mdx`<br>`guides/database/mysql.mdx`<br>`guides/database/sqlserver.mdx`<br>`guides/database/multi-db.mdx`<br>`reference/config/drivers.mdx` | 🚧 À FAIRE |
| `MIGRATION-BREAKOUT-SELECTIF.md` | 1390 | `guides/breakout/selective.mdx`<br>`reference/cli/process-cases.mdx` | 🚧 À FAIRE |
| `CSWEB-OAUTH-AUTHENTICATION.md` | 1019 | `reference/api/oauth.mdx` | 🚧 À FAIRE |
| `WEBHOOKS-INTEGRATION.md` | 1195 | `guides/admin/webhooks.mdx`<br>`reference/api/webhooks.mdx` | 🚧 À FAIRE |
| `DOCKER-DEPLOYMENT.md` | 641 | `guides/deployment/docker-dev.mdx`<br>`guides/deployment/docker-prod.mdx` | 🚧 À FAIRE |
| `INSTALLATION-CSWEB-VANILLA.md` | 688 | `getting-started/installation.mdx` (section)<br>`guides/deployment/vanilla-migration.mdx` | 🚧 À FAIRE |

**NOUVEAU Contenu :**
- `reference/troubleshooting/common-issues.mdx` (400 lignes)
- `reference/troubleshooting/faq.mdx` (300 lignes)
- `reference/troubleshooting/errors.mdx` (250 lignes)
- `getting-started/first-breakout.mdx` (450 lignes) ✅ FAIT
- `getting-started/verify.mdx` (500 lignes) ✅ FAIT
- `getting-started/next-steps.mdx` (550 lignes) ✅ FAIT

---

## 🚀 Prochaines Actions

### Immédiatement (Phase 3)

1. **Créer Troubleshooting** (PRIORITÉ)
   ```bash
   touch pages/reference/troubleshooting/common-issues.mdx
   touch pages/reference/troubleshooting/faq.mdx
   touch pages/reference/troubleshooting/errors.mdx
   ```

2. **Migrer Guides Breakout**
   - Lire `docs/MIGRATION-BREAKOUT-SELECTIF.md`
   - Diviser en 3 pages (selective, scheduled, monitoring)
   - Ajouter Callouts + Tabs

3. **Migrer Guides Database**
   - Lire `docs/CONFIGURATION-MULTI-DATABASE.md`
   - Séparer par SGBD (PostgreSQL, MySQL, SQL Server)
   - Créer guide multi-db overview

### Ensuite (Phase 4)

4. **Polish & Vérification**
   - Tester recherche full-text
   - Vérifier tous les liens
   - Mobile responsive
   - Proofreading

5. **Déploiement Vercel**
   - Connecter repo
   - Configurer build
   - Custom domain
   - Analytics

---

## 📞 Support

**Questions/Issues :**
- GitHub Issues : https://github.com/BOUNADRAME/pg_csweb8_latest_2026/issues
- Discord : https://discord.gg/csweb-community
- Email : docs@csweb-community.org

---

**Auteur :** Bouna DRAME
**Date :** 15 Mars 2026
**Version :** 2.0.0-alpha
**Status :** Phase 1+2 ✅ COMPLÉTÉES | Phase 3+4 🚧 EN COURS

**Temps Investi :** 7h30 / 28-38h estimées
**Progression :** ~25% (Getting Started complet)
