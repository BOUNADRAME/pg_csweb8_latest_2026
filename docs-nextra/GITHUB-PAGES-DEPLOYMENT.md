# Déploiement Nextra Documentation sur GitHub Pages

## 🎯 Objectif

Déployer automatiquement la documentation CSWeb Community Platform (Nextra) sur GitHub Pages à chaque push vers `master`.

---

## ✅ Configuration Complète

### 1. Configuration Next.js pour Export Statique

**Fichier modifié:** `next.config.js`

```js
const isProduction = process.env.NODE_ENV === 'production'
const assetPrefix = isProduction ? '/pg_csweb8_latest_2026' : ''

module.exports = withNextra({
  // GitHub Pages configuration
  basePath: isProduction ? '/pg_csweb8_latest_2026' : '',
  assetPrefix: assetPrefix,
  output: 'export',  // ← Export statique pour GitHub Pages

  images: {
    unoptimized: true  // ← Requis pour export statique
  },

  trailingSlash: true,  // ← Meilleure compatibilité GitHub Pages
})
```

**Important:**
- `output: 'export'` génère un dossier `out/` avec HTML statique
- `basePath` correspond au nom du repository GitHub
- `trailingSlash: true` pour URLs propres (`/page/` au lieu de `/page`)

---

### 2. GitHub Actions Workflow

**Fichier créé:** `.github/workflows/deploy-nextra-docs.yml`

**Workflow en 2 jobs:**

#### Job 1: Build
- Checkout code
- Setup Node.js 18
- Install dependencies (`npm ci`)
- Build Next.js (`npm run build`)
- Upload artifact vers GitHub Pages

#### Job 2: Deploy
- Deploy sur GitHub Pages (seulement sur push vers `master`)
- Génère URL: `https://BOUNADRAME.github.io/pg_csweb8_latest_2026/`

**Déclencheurs:**
- Push vers `master` (branch `docs-nextra/**`)
- Pull Request vers `master`
- Manuel (`workflow_dispatch`)

---

### 3. Fichier .nojekyll

**Fichier créé:** `public/.nojekyll`

Ce fichier vide indique à GitHub Pages de **ne pas traiter le site avec Jekyll**. Essentiel pour Next.js car :
- Jekyll ignore les dossiers commençant par `_` (comme `_next/`)
- Sans `.nojekyll`, les assets Next.js ne seront pas servis

---

## 🚀 Activation GitHub Pages

### Sur GitHub.com

1. **Aller dans Settings du repo**
   ```
   https://github.com/BOUNADRAME/pg_csweb8_latest_2026/settings/pages
   ```

2. **Configurer Source**
   - Source: `GitHub Actions`
   - ~~Branch: `gh-pages`~~ (pas nécessaire avec Actions)

3. **Vérifier Permissions**
   - Settings → Actions → General
   - Workflow permissions: ✅ `Read and write permissions`
   - ✅ `Allow GitHub Actions to create and approve pull requests`

4. **Sauvegarder**

---

## 📦 Build Local (Test)

### Développement

```bash
cd docs-nextra
npm run dev
# http://localhost:3000
```

### Build Production (Test avant deploy)

```bash
cd docs-nextra

# Build avec export statique
NODE_ENV=production npm run build

# Vérifier le dossier out/
ls -lah out/
du -sh out/  # Taille: ~3.4MB

# Tester localement avec serveur HTTP
npx serve out -p 3001
# http://localhost:3001/pg_csweb8_latest_2026/
```

**Résultat attendu:**
- Dossier `out/` créé
- 8 pages HTML générées
- Taille: ~3.4MB
- Toutes les pages accessibles

---

## 🔄 Workflow de Déploiement

### Automatique (Push vers master)

```bash
# 1. Modifier une page MDX
vim docs-nextra/pages/getting-started/index.mdx

# 2. Commit et push
git add docs-nextra/
git commit -m "Update getting started page"
git push origin master

# 3. GitHub Actions s'exécute automatiquement
# - Build (2-3 minutes)
# - Deploy (30 secondes)

# 4. Vérifier déploiement
# https://github.com/BOUNADRAME/pg_csweb8_latest_2026/actions
```

### Manuel (workflow_dispatch)

1. Aller sur GitHub Actions
2. Sélectionner workflow "Deploy Nextra Documentation"
3. Cliquer "Run workflow"
4. Sélectionner branch `master`
5. Cliquer "Run workflow"

---

## 🌐 URLs de Production

### GitHub Pages

**URL principale:**
```
https://BOUNADRAME.github.io/pg_csweb8_latest_2026/
```

**Pages spécifiques:**
```
https://BOUNADRAME.github.io/pg_csweb8_latest_2026/
https://BOUNADRAME.github.io/pg_csweb8_latest_2026/getting-started/
https://BOUNADRAME.github.io/pg_csweb8_latest_2026/getting-started/installation/
https://BOUNADRAME.github.io/pg_csweb8_latest_2026/getting-started/first-breakout/
https://BOUNADRAME.github.io/pg_csweb8_latest_2026/getting-started/verify/
https://BOUNADRAME.github.io/pg_csweb8_latest_2026/getting-started/next-steps/
```

**Note:** Les URLs se terminent par `/` grâce à `trailingSlash: true`

---

## 🎨 Custom Domain (Optionnel)

### Configurer un domaine personnalisé

**Exemple:** `docs.csweb-community.org`

#### 1. Configurer DNS

Ajouter un enregistrement CNAME :

```
Type: CNAME
Name: docs
Value: BOUNADRAME.github.io
TTL: 3600
```

#### 2. Configurer GitHub Pages

1. Settings → Pages
2. Custom domain: `docs.csweb-community.org`
3. ✅ Enforce HTTPS
4. Save

#### 3. Créer fichier CNAME

```bash
echo "docs.csweb-community.org" > docs-nextra/public/CNAME
git add docs-nextra/public/CNAME
git commit -m "Add custom domain CNAME"
git push
```

#### 4. Mettre à jour next.config.js

```js
const isProduction = process.env.NODE_ENV === 'production'
const useCustomDomain = process.env.USE_CUSTOM_DOMAIN === 'true'

module.exports = withNextra({
  basePath: (isProduction && !useCustomDomain) ? '/pg_csweb8_latest_2026' : '',
  assetPrefix: (isProduction && !useCustomDomain) ? '/pg_csweb8_latest_2026' : '',
  // ...
})
```

**Nouvelle URL:**
```
https://docs.csweb-community.org/
```

---

## 📊 Vérification Déploiement

### Checklist Post-Déploiement

- [ ] Build GitHub Actions réussi (pas d'erreurs)
- [ ] Deploy GitHub Actions réussi
- [ ] URL principale accessible (`https://BOUNADRAME.github.io/pg_csweb8_latest_2026/`)
- [ ] Landing page s'affiche correctement
- [ ] Navigation sidebar fonctionne
- [ ] Recherche full-text fonctionne
- [ ] Dark mode fonctionne
- [ ] Images chargent correctement
- [ ] Code snippets stylisés correctement
- [ ] Callouts stylisés correctement
- [ ] Toutes les pages accessibles :
  - [ ] `/getting-started/`
  - [ ] `/getting-started/installation/`
  - [ ] `/getting-started/first-breakout/`
  - [ ] `/getting-started/verify/`
  - [ ] `/getting-started/next-steps/`

### Commandes de Vérification

```bash
# Vérifier que le site est accessible
curl -I https://BOUNADRAME.github.io/pg_csweb8_latest_2026/

# Vérifier page spécifique
curl https://BOUNADRAME.github.io/pg_csweb8_latest_2026/getting-started/ | grep -i "bienvenue"

# Vérifier que .nojekyll est présent
curl -I https://BOUNADRAME.github.io/pg_csweb8_latest_2026/.nojekyll
```

---

## 🐛 Troubleshooting

### Problème: 404 sur GitHub Pages

**Cause:** Mauvais basePath ou assetPrefix

**Solution:**
```js
// next.config.js
basePath: '/pg_csweb8_latest_2026',  // ← Doit correspondre au nom du repo
```

### Problème: Assets (_next/) ne chargent pas

**Cause:** Fichier `.nojekyll` manquant

**Solution:**
```bash
touch docs-nextra/public/.nojekyll
git add docs-nextra/public/.nojekyll
git commit -m "Add .nojekyll for GitHub Pages"
git push
```

### Problème: Build échoue sur GitHub Actions

**Cause:** Versions Node.js différentes ou `package-lock.json` manquant

**Solution:**
```bash
# Régénérer package-lock.json
cd docs-nextra
rm -rf node_modules package-lock.json
npm install
git add package-lock.json
git commit -m "Update package-lock.json"
git push
```

### Problème: Pages vides (404 internes)

**Cause:** `trailingSlash` mal configuré

**Solution:**
```js
// next.config.js
trailingSlash: true,  // ← Requis pour GitHub Pages
```

### Problème: Workflow ne se déclenche pas

**Cause:** Permissions GitHub Actions

**Solution:**
1. Settings → Actions → General
2. Workflow permissions: `Read and write permissions`
3. ✅ `Allow GitHub Actions to create and approve pull requests`

---

## 📈 Monitoring

### GitHub Actions

**Voir les déploiements:**
```
https://github.com/BOUNADRAME/pg_csweb8_latest_2026/actions
```

**Logs détaillés:**
- Cliquer sur un workflow run
- Cliquer sur "Build" ou "Deploy"
- Voir les logs en temps réel

### GitHub Pages Status

**Vérifier status:**
```
https://github.com/BOUNADRAME/pg_csweb8_latest_2026/deployments
```

**Historique déploiements:**
- Settings → Pages
- Voir "Last deployment"

---

## 🎯 Prochaines Étapes

### Améliorer le Déploiement

1. **Cache NPM** (déjà configuré)
   - `cache: 'npm'` dans `actions/setup-node@v4`

2. **Preview Deployments pour PRs**
   - Utiliser Vercel ou Netlify pour previews

3. **Analytics**
   - Ajouter Google Analytics dans `theme.config.jsx`
   - Ou utiliser Vercel Analytics

4. **SEO**
   - Ajouter `sitemap.xml`
   - Ajouter `robots.txt`

5. **Performance**
   - Lighthouse CI dans GitHub Actions
   - Budget de performance

---

## 📝 Résumé Configuration

| Fichier | Modification | Status |
|---------|--------------|--------|
| `next.config.js` | `output: 'export'`, basePath, assetPrefix | ✅ FAIT |
| `public/.nojekyll` | Fichier vide | ✅ FAIT |
| `.github/workflows/deploy-nextra-docs.yml` | Workflow Build + Deploy | ✅ FAIT |
| GitHub Settings | Pages source: GitHub Actions | 🚧 À FAIRE |

**Actions Requises:**
1. ✅ Fichiers de configuration créés
2. 🚧 Activer GitHub Pages dans Settings
3. 🚧 Push vers master pour déclencher premier déploiement
4. 🚧 Vérifier URL GitHub Pages

---

## 🚀 Déploiement Initial

### Commandes pour Premier Déploiement

```bash
# 1. Vérifier que tout est commité
git status

# 2. Ajouter les nouveaux fichiers
git add docs-nextra/ .github/workflows/deploy-nextra-docs.yml

# 3. Commit
git commit -m "Add Nextra documentation with GitHub Pages deployment

- Setup Next.js with static export
- Create GitHub Actions workflow for auto-deploy
- Add .nojekyll for GitHub Pages compatibility
- Configure basePath for repository sub-path
- 6 pages Getting Started completed
- 3 custom React components (Callout, Tabs, CodeBlock)
- Navigation structure with 14 _meta.json files
"

# 4. Push vers master
git push origin master

# 5. Vérifier GitHub Actions
# https://github.com/BOUNADRAME/pg_csweb8_latest_2026/actions

# 6. Attendre build + deploy (2-3 minutes)

# 7. Vérifier site déployé
open https://BOUNADRAME.github.io/pg_csweb8_latest_2026/
```

---

**Auteur:** Bouna DRAME
**Date:** 15 Mars 2026
**Version:** 1.0.0
**Status:** ✅ Configuration Complète - Prêt pour Déploiement
