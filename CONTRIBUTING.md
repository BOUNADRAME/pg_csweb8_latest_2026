# Contributing to CSWeb Community Platform

> Merci de votre intérêt pour contribuer à CSWeb Community Platform ! 🙏

Ce document vous guide pour contribuer au projet de manière efficace.

---

## 📋 Table des Matières

1. [Code de Conduite](#code-de-conduite)
2. [Comment puis-je contribuer ?](#comment-puis-je-contribuer)
3. [Processus de développement](#processus-de-développement)
4. [Style de code](#style-de-code)
5. [Commits et messages](#commits-et-messages)
6. [Pull Requests](#pull-requests)
7. [Signaler des bugs](#signaler-des-bugs)
8. [Proposer des fonctionnalités](#proposer-des-fonctionnalités)

---

## Code de Conduite

Ce projet adhère au [Code of Conduct](CODE_OF_CONDUCT.md) (à venir). En participant, vous vous engagez à respecter ses termes.

**Principes clés :**
- 🤝 Soyez respectueux et inclusif
- 💬 Communiquez de manière constructive
- 🎯 Restez concentré sur les objectifs du projet
- 🙏 Soyez patient avec les nouveaux contributeurs

---

## Comment puis-je contribuer ?

### 1. Signaler des bugs 🐛

Les rapports de bugs nous aident à améliorer le projet !

**Avant de signaler un bug :**
- ✅ Vérifiez que le bug n'a pas déjà été signalé dans les [Issues](https://github.com/BOUNADRAME/pg_csweb8_latest_2026/issues)
- ✅ Vérifiez que vous utilisez la dernière version
- ✅ Consultez la [documentation](docs/) et [GETTING-STARTED.md](GETTING-STARTED.md)

**Comment signaler un bug :**
1. Créer une [nouvelle issue](https://github.com/BOUNADRAME/pg_csweb8_latest_2026/issues/new/choose)
2. Utiliser le template "Bug Report"
3. Fournir le maximum de détails (OS, version, logs, screenshots)

### 2. Proposer des fonctionnalités ✨

Nous sommes ouverts aux nouvelles idées !

**Avant de proposer une fonctionnalité :**
- ✅ Vérifiez le [CHANGELOG.md](CHANGELOG.md) et la roadmap
- ✅ Cherchez si une suggestion similaire existe déjà
- ✅ Assurez-vous que ça s'aligne avec la vision du projet

**Comment proposer une fonctionnalité :**
1. Créer une [nouvelle issue](https://github.com/BOUNADRAME/pg_csweb8_latest_2026/issues/new/choose)
2. Utiliser le template "Feature Request"
3. Expliquer le problème résolu et votre solution proposée

### 3. Améliorer la documentation 📖

La documentation est cruciale pour l'adoption du projet !

**Types de contributions documentation :**
- Corriger des typos ou clarifier des sections
- Ajouter des exemples ou tutoriels
- Traduire en anglais (docs FR → EN)
- Créer des vidéos tutoriels

**Comment contribuer :**
1. Les docs sont dans le dossier `docs/`
2. Fork → Modifier → Pull Request
3. Suivre le style Markdown existant

### 4. Contribuer du code 💻

**Domaines où nous avons besoin d'aide :**
- Docker Compose production-ready
- Admin Panel React
- Scheduler Web UI
- Tests unitaires (PHPUnit)
- API REST documentation (Swagger/OpenAPI)

---

## Processus de développement

### Setup environnement local

```bash
# 1. Fork le projet sur GitHub

# 2. Cloner votre fork
git clone https://github.com/VOTRE_USERNAME/pg_csweb8_latest_2026.git
cd pg_csweb8_latest_2026

# 3. Ajouter le repo original comme upstream
git remote add upstream https://github.com/BOUNADRAME/pg_csweb8_latest_2026.git

# 4. Créer une branche pour votre feature
git checkout -b feature/ma-nouvelle-feature

# 5. Configurer l'environnement
cp .env.example .env
# Éditer .env avec vos valeurs locales

# 6. Lancer Docker
docker-compose up -d

# 7. Vérifier que tout fonctionne
docker-compose ps
curl http://localhost:8080/api/health
```

### Workflow de développement

```bash
# 1. Synchroniser avec upstream régulièrement
git fetch upstream
git rebase upstream/master

# 2. Faire vos changements
# ... éditez les fichiers ...

# 3. Tester vos changements
# Pour PHP/Symfony :
docker exec -it csweb_app php bin/phpunit

# Pour React Admin Panel :
cd admin-panel
npm test

# 4. Commiter vos changements
git add .
git commit -m "Type: Description courte"

# 5. Pusher vers votre fork
git push origin feature/ma-nouvelle-feature

# 6. Créer une Pull Request sur GitHub
```

---

## Style de code

### PHP (Symfony)

**Suivre les standards PSR-12 :**

```php
<?php

namespace AppBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;

class ExampleController extends AbstractController
{
    /**
     * Description de la méthode
     *
     * @param string $param Description du paramètre
     * @return JsonResponse
     */
    public function exampleAction(string $param): JsonResponse
    {
        // Code avec indentation 4 espaces
        $result = $this->someService->process($param);

        return new JsonResponse([
            'success' => true,
            'data' => $result
        ]);
    }
}
```

**Vérifier le code :**
```bash
# PHP CS Fixer
docker exec -it csweb_app php vendor/bin/php-cs-fixer fix src/

# PHPStan (analyse statique)
docker exec -it csweb_app php vendor/bin/phpstan analyse src/
```

### JavaScript/TypeScript (React)

**Utiliser ESLint + Prettier :**

```typescript
// Exemple de composant React
import React, { useState, useEffect } from 'react';

interface Props {
  title: string;
  onSubmit: (data: FormData) => void;
}

export const ExampleComponent: React.FC<Props> = ({ title, onSubmit }) => {
  const [data, setData] = useState<FormData | null>(null);

  useEffect(() => {
    // Effect logic
  }, []);

  return (
    <div className="container">
      <h1>{title}</h1>
      {/* Component JSX */}
    </div>
  );
};
```

**Vérifier le code :**
```bash
cd admin-panel
npm run lint
npm run format
```

### Markdown (Documentation)

**Style :**
- Utiliser des headers clairs (`#`, `##`, `###`)
- Ajouter des émojis pour la lisibilité (optionnel)
- Inclure des exemples de code
- Lier vers d'autres docs quand pertinent

**Exemple :**
```markdown
## 🚀 Installation

Suivez ces étapes :

1. **Cloner le projet :**
   ```bash
   git clone https://github.com/...
   ```

2. **Configurer l'environnement :**
   Voir [.env.example](.env.example) pour les variables.

3. **Lancer Docker :**
   ```bash
   docker-compose up -d
   ```
```

---

## Commits et messages

### Convention de commits

Nous utilisons [Conventional Commits](https://www.conventionalcommits.org/) :

**Format :**
```
<type>: <description courte>

[corps optionnel]

[footer optionnel]
```

**Types :**
- `feat:` - Nouvelle fonctionnalité
- `fix:` - Correction de bug
- `docs:` - Documentation uniquement
- `style:` - Formatage, points-virgules, etc
- `refactor:` - Refactoring de code
- `perf:` - Amélioration de performance
- `test:` - Ajout ou correction de tests
- `chore:` - Maintenance, dépendances, config

**Exemples :**

```bash
# Feature
git commit -m "feat: Add breakout scheduler UI component"

# Bug fix
git commit -m "fix: Resolve PostgreSQL connection timeout issue"

# Documentation
git commit -m "docs: Update GETTING-STARTED with Docker troubleshooting"

# Refactoring
git commit -m "refactor: Extract breakout logic into separate service"

# Breaking change
git commit -m "feat!: Change API authentication to OAuth2

BREAKING CHANGE: The JWT authentication has been replaced with OAuth2.
Update your .env with new OAUTH_CLIENT_ID and OAUTH_CLIENT_SECRET."
```

---

## Pull Requests

### Avant de soumettre une PR

**Checklist :**
- [ ] Mon code suit le style du projet (PSR-12, ESLint)
- [ ] J'ai testé mes changements localement
- [ ] J'ai ajouté/mis à jour les tests si nécessaire
- [ ] J'ai mis à jour la documentation
- [ ] Tous les tests passent (`docker exec -it csweb_app php bin/phpunit`)
- [ ] Ma branche est à jour avec `upstream/master`
- [ ] Mes commits suivent la convention Conventional Commits

### Processus de review

1. **Création de la PR :**
   - Titre clair et descriptif
   - Description complète (utiliser le template)
   - Lier à l'issue correspondante
   - Ajouter des screenshots si changements UI

2. **Review :**
   - Les mainteneurs vont review votre code
   - Soyez réactif aux commentaires
   - Apportez les modifications demandées

3. **Merge :**
   - Une fois approuvée, un mainteneur mergera votre PR
   - Votre contribution sera visible dans le prochain CHANGELOG

### Taille des PR

**Recommandations :**
- ✅ Petites PR focalisées (1 feature/fix)
- ✅ Maximum 500 lignes de changements
- ❌ Éviter les "mega-PR" avec plein de changements

**Si votre PR est grande :**
- Séparez-la en plusieurs PR plus petites
- Créez une issue "Epic" pour tracker le tout

---

## Signaler des bugs

### Template Bug Report

Lorsque vous créez une issue de bug, incluez :

**1. Description claire du bug**
```
Quand je lance `docker-compose up`, j'obtiens une erreur...
```

**2. Étapes pour reproduire**
```
1. Cloner le repo
2. Copier .env.example vers .env
3. Lancer docker-compose up -d
4. Voir l'erreur dans les logs
```

**3. Comportement attendu**
```
Les services devraient démarrer sans erreur.
```

**4. Comportement actuel**
```
Erreur: "connection refused to postgres:5432"
```

**5. Environnement**
```
- OS: macOS 13.2
- Docker: 24.0.1
- Docker Compose: 2.18.0
- Version CSWeb: v1.0.0-beta
```

**6. Logs**
```bash
docker-compose logs postgres
# ... collez les logs pertinents ...
```

---

## Proposer des fonctionnalités

### Template Feature Request

Lorsque vous proposez une feature, incluez :

**1. Résumé de la fonctionnalité**
```
Ajouter un bouton d'export CSV dans le monitoring des logs.
```

**2. Motivation**
```
En tant qu'administrateur, je voudrais exporter les logs en CSV
afin de les analyser dans Excel ou faire des rapports.
```

**3. Solution proposée**
```
Ajouter un bouton "Export CSV" dans /monitoring/logs qui :
- Filtre les logs selon les critères actuels
- Génère un CSV avec colonnes: timestamp, level, message, dictionary
- Télécharge le fichier automatiquement
```

**4. Alternatives considérées**
```
- Export JSON : Moins pratique pour l'analyse
- Export PDF : Pas adapté pour des données tabulaires
```

**5. Impact estimé**
```
- Utilisateurs concernés : Administrateurs
- Priorité : Moyenne (nice to have)
- Complexité : Faible (1-2 jours)
```

---

## Ressources utiles

**Documentation :**
- [README.md](README.md) - Vue d'ensemble
- [GETTING-STARTED.md](GETTING-STARTED.md) - Guide démarrage
- [docs/](docs/) - Documentation complète
- [CHANGELOG.md](CHANGELOG.md) - Historique des versions

**Projet :**
- [GitHub Issues](https://github.com/BOUNADRAME/pg_csweb8_latest_2026/issues)
- [GitHub Projects](https://github.com/BOUNADRAME/pg_csweb8_latest_2026/projects) (à venir)
- Discord : https://discord.gg/csweb-community (à venir)

**Références externes :**
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Symfony Best Practices](https://symfony.com/doc/current/best_practices.html)
- [React Best Practices](https://react.dev/learn)

---

## Questions ?

**Vous avez des questions sur comment contribuer ?**

- 💬 Ouvrez une [issue de type "Question"](https://github.com/BOUNADRAME/pg_csweb8_latest_2026/issues/new/choose)
- 📧 Email : bdrame@statinfo.sn
- 💬 Discord : https://discord.gg/csweb-community (à venir)

---

## Remerciements

**Merci à tous nos contributeurs ! 🙏**

Votre nom apparaîtra dans [CONTRIBUTORS.md](CONTRIBUTORS.md) et dans les release notes.

---

<div align="center">

**[⬆ Retour en haut](#contributing-to-csweb-community-platform)**

**Prêt à contribuer ? [Créez votre première PR](https://github.com/BOUNADRAME/pg_csweb8_latest_2026/compare) ! 🚀**

</div>
