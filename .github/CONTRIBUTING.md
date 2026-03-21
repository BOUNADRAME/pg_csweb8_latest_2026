# Guide de Contribution - CSWeb Community Platform

Merci de votre intérêt pour contribuer à CSWeb Community Platform ! 🎉

## 📋 Processus de Contribution

### 1. Fork & Clone

```bash
# Fork le repo sur GitHub, puis :
git clone https://github.com/VOTRE-USERNAME/csweb-community.git
cd csweb-community
git remote add upstream https://github.com/BOUNADRAME/csweb-community.git
```

### 2. Créer une Branche

**❌ Ne jamais travailler directement sur `master` !**

```bash
# Créer une branche descriptive
git checkout -b feature/nom-de-votre-fonctionnalite

# Ou pour un bugfix
git checkout -b fix/description-du-bug
```

### 3. Développer & Tester

- Écrivez du code clair et documenté
- Testez vos changements localement avec Docker
- Suivez les conventions du projet (voir ci-dessous)

### 4. Commit

```bash
# Commits clairs et descriptifs
git add .
git commit -m "Type: Description concise du changement

Explication détaillée si nécessaire.
"
```

**Types de commits :**
- `Feat:` Nouvelle fonctionnalité
- `Fix:` Correction de bug
- `Docs:` Documentation
- `Refactor:` Refactoring sans changement fonctionnel
- `Test:` Ajout de tests
- `Chore:` Tâches de maintenance

### 5. Push & Pull Request

```bash
# Push vers votre fork
git push origin feature/nom-de-votre-fonctionnalite
```

Puis sur GitHub :
1. Allez sur votre fork
2. Cliquez sur **"Compare & pull request"**
3. Remplissez le template de PR
4. Attendez la review

---

## ✅ Checklist avant PR

- [ ] Mon code fonctionne localement avec Docker
- [ ] J'ai testé les fonctionnalités modifiées
- [ ] J'ai mis à jour la documentation si nécessaire
- [ ] Mes commits sont clairs et descriptifs
- [ ] Mon code respecte les conventions du projet
- [ ] J'ai résolu tous les conflits avec `master`

---

## 🔒 Protection de la Branche Master

La branche `master` est protégée :
- ❌ Pas de push direct
- ✅ Pull requests obligatoires
- ✅ Review requise avant merge
- ✅ Tests CI/CD doivent passer

---

## 🛠️ Conventions du Projet

### PHP/Symfony
- PSR-12 code style
- Type hinting obligatoire
- PHPDoc pour les méthodes publiques

### Documentation (Nextra)
- Markdown avec front matter
- Langue : Français
- Ton : Positif et constructif

### Docker
- Tester avec `docker compose --profile local-postgres up -d`
- Vérifier les healthchecks

---

## 📞 Questions ?

- **Issues** : [GitHub Issues](https://github.com/BOUNADRAME/csweb-community/issues)
- **Discussions** : [GitHub Discussions](https://github.com/BOUNADRAME/csweb-community/discussions)

Merci de contribuer à CSWeb Community Platform ! 🚀
