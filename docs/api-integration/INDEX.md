# Intégration CSWeb - Index de Documentation

> Navigation rapide vers la documentation des webhooks CSWeb et l'intégration API

---

## 🚀 Démarrage Rapide

### Pour commencer (5 minutes)

1. **[CSWEB-QUICK-REFERENCE.md](CSWEB-QUICK-REFERENCE.md)** ⚡
   - Commandes curl essentielles
   - Exemples d'utilisation rapide
   - Codes d'erreur et diagnostic
   - **Idéal pour:** Administration quotidienne

### Pour comprendre (45 minutes)

2. **[CSWEB-WEBHOOKS-GUIDE.md](CSWEB-WEBHOOKS-GUIDE.md)** 📘
   - Architecture complète (Frontend ↔ Kairos API ↔ CSWeb)
   - Détails des 3 webhooks PHP
   - Déploiement pas-à-pas
   - Sécurité et authentification
   - Monitoring et logs
   - Troubleshooting complet
   - **Idéal pour:** Comprendre le système complet

### Pour déployer (10 minutes)

3. **[csweb-webhook/README.md](csweb-webhook/README.md)** 🛠️
   - Documentation des scripts PHP
   - Instructions d'installation
   - Configuration Apache
   - Tests de validation
   - **Idéal pour:** Déploiement sur serveur CSWeb

### Pour l'interface (10 minutes)

4. **[api-cspro-breakout.md](api-cspro-breakout.md)** 🖥️
   - Référence API pour le frontend
   - Endpoints REST Kairos
   - Formats de réponse JSON
   - Workflow d'intégration frontend
   - **Idéal pour:** Développeurs frontend

---

## 📚 Par Cas d'Usage

### Je veux...

#### ...déclencher un breakout manuellement
```bash
# Voir: CSWEB-QUICK-REFERENCE.md → Section "Breakout"
curl -X POST http://localhost:8080/api/admin/cspro/breakout/EVAL_PRODUCTEURS_USAID/trigger \
  -H "Authorization: Bearer {JWT_TOKEN}"
```
→ [CSWEB-QUICK-REFERENCE.md#breakout](CSWEB-QUICK-REFERENCE.md#-breakout)

---

#### ...lire les logs CSWeb en temps réel
```bash
# Voir: CSWEB-QUICK-REFERENCE.md → Section "Logs CSWeb"
curl "http://localhost:8080/api/admin/cspro/logs?file=ui.log&lines=200&level=ERROR" \
  -H "Authorization: Bearer {JWT_TOKEN}"
```
→ [CSWEB-QUICK-REFERENCE.md#-logs-csweb](CSWEB-QUICK-REFERENCE.md#-logs-csweb)

---

#### ...configurer un nouveau dictionnaire pour le breakout
```bash
# Voir: CSWEB-QUICK-REFERENCE.md → Section "Schémas Dictionnaires"
curl -X POST http://localhost:8080/api/admin/cspro/schemas \
  -H "Authorization: Bearer {JWT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "dictionaryId": 3,
    "hostName": "localhost",
    "schemaName": "kairos_dev",
    "schemaUserName": "kairos_dev",
    "schemaPassword": "kairos_dev_pwd"
  }'
```
→ [CSWEB-WEBHOOKS-GUIDE.md#8-exemples-dutilisation](CSWEB-WEBHOOKS-GUIDE.md#8-exemples-dutilisation)

---

#### ...automatiser les breakouts avec un scheduler
```bash
# Voir: CSWEB-QUICK-REFERENCE.md → Section "Scheduler"
curl -X PATCH http://localhost:8080/api/admin/scheduler/jobs/BREAKOUT_EVAL_PRODUCTEURS_USAID \
  -H "Authorization: Bearer {JWT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "cronExpression": "0 0 1 * * ?",  # Tous les jours à 1h
    "enabled": true
  }'
```
→ [CSWEB-WEBHOOKS-GUIDE.md#44-scheduler-dynamique](CSWEB-WEBHOOKS-GUIDE.md#44-scheduler-dynamique)

---

#### ...déployer les webhooks sur le serveur CSWeb
```bash
# Voir: csweb-webhook/README.md → Section "Déploiement"
ssh admin@193.203.15.16
sudo cp breakout-webhook.php /var/www/html/kairos/
sudo chown www-data:www-data /var/www/html/kairos/breakout-webhook.php
```
→ [csweb-webhook/README.md#-déploiement](csweb-webhook/README.md#-déploiement)

---

#### ...comprendre l'architecture globale
→ [CSWEB-WEBHOOKS-GUIDE.md#1-architecture-globale](CSWEB-WEBHOOKS-GUIDE.md#1-architecture-globale)

Schéma:
```
┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│   Frontend UI    │         │   Kairos API     │         │   CSWeb Server   │
│  (Angular/React) │────────▶│  (Spring Boot)   │────────▶│  (PHP Symfony)   │
└──────────────────┘         └──────────────────┘         └──────────────────┘
                                      │                             │
                                      └────────── WEBHOOKS ─────────┘
                                           (Bearer Token)
```

---

#### ...résoudre une erreur "Invalid token"
→ [CSWEB-WEBHOOKS-GUIDE.md#71-erreurs-fréquentes](CSWEB-WEBHOOKS-GUIDE.md#71-erreurs-fréquentes)

**Cause:** Token différent entre Kairos et CSWeb
**Solution:** Vérifier que `CSPRO_WEBHOOK_TOKEN` (Kairos .env) = `BREAKOUT_WEBHOOK_TOKEN` (CSWeb Apache)

---

## 🗂️ Structure des Fichiers

```
docs/api-integration/
├── INDEX.md                          ← Vous êtes ici
│
├── CSWEB-WEBHOOKS-GUIDE.md           ← 📘 Guide complet (60+ pages)
│   ├── 1. Architecture Globale
│   ├── 2. Les 3 Webhooks CSWeb
│   ├── 3. Déploiement sur le Serveur CSWeb
│   ├── 4. Gestion à Distance depuis Kairos API
│   ├── 5. Sécurité et Authentification
│   ├── 6. Monitoring et Logs
│   ├── 7. Troubleshooting
│   └── 8. Exemples d'Utilisation
│
├── CSWEB-QUICK-REFERENCE.md          ← ⚡ Référence rapide (10 pages)
│   ├── Authentification
│   ├── Dictionnaires CSPro
│   ├── Breakout
│   ├── Scheduler
│   ├── Logs CSWeb
│   ├── Schémas Dictionnaires
│   └── Diagnostic & Maintenance
│
├── api-cspro-breakout.md             ← 🖥️ Référence API Frontend
│   ├── Authentification JWT
│   ├── Endpoints Breakout
│   ├── Endpoints Scheduler
│   └── Format des log entries
│
└── csweb-webhook/                    ← 🛠️ Scripts PHP + Docs
    ├── README.md                     ← Documentation scripts
    ├── breakout-webhook.php          ← Webhook 1: Breakout
    ├── log-reader-webhook.php        ← Webhook 2: Logs
    └── dictionary-schema-webhook.php ← Webhook 3: Schémas
```

---

## 🎯 Parcours de Lecture Recommandé

### Pour un Administrateur Système

1. **[csweb-webhook/README.md](csweb-webhook/README.md)** (5 min)
   → Comprendre les scripts PHP à déployer

2. **[CSWEB-WEBHOOKS-GUIDE.md](CSWEB-WEBHOOKS-GUIDE.md)** → Section 3 (15 min)
   → Déploiement sur le serveur CSWeb

3. **[CSWEB-QUICK-REFERENCE.md](CSWEB-QUICK-REFERENCE.md)** → Section Diagnostic (5 min)
   → Commandes de diagnostic et maintenance

4. **[CSWEB-WEBHOOKS-GUIDE.md](CSWEB-WEBHOOKS-GUIDE.md)** → Section 7 (10 min)
   → Troubleshooting des erreurs courantes

**Temps total:** ~35 minutes

---

### Pour un Développeur Backend (Kairos API)

1. **[CSWEB-WEBHOOKS-GUIDE.md](CSWEB-WEBHOOKS-GUIDE.md)** → Section 1 (10 min)
   → Architecture globale et flux de données

2. **[CSWEB-WEBHOOKS-GUIDE.md](CSWEB-WEBHOOKS-GUIDE.md)** → Section 4 (20 min)
   → Gestion à distance depuis Kairos API

3. **[CSWEB-WEBHOOKS-GUIDE.md](CSWEB-WEBHOOKS-GUIDE.md)** → Section 5 (15 min)
   → Sécurité et authentification

4. **[CSWEB-QUICK-REFERENCE.md](CSWEB-QUICK-REFERENCE.md)** (10 min)
   → Référence rapide pour tests

**Temps total:** ~55 minutes

---

### Pour un Développeur Frontend

1. **[api-cspro-breakout.md](api-cspro-breakout.md)** (10 min)
   → Référence API complète

2. **[CSWEB-WEBHOOKS-GUIDE.md](CSWEB-WEBHOOKS-GUIDE.md)** → Section 8 (15 min)
   → Exemples d'utilisation (JavaScript)

3. **[CSWEB-QUICK-REFERENCE.md](CSWEB-QUICK-REFERENCE.md)** → Section Workflow (5 min)
   → Workflow typique d'intégration

**Temps total:** ~30 minutes

---

### Pour un Chef de Projet / Product Owner

1. **[CSWEB-WEBHOOKS-GUIDE.md](CSWEB-WEBHOOKS-GUIDE.md)** → Section 1 (10 min)
   → Vue d'ensemble architecture

2. **[CSWEB-WEBHOOKS-GUIDE.md](CSWEB-WEBHOOKS-GUIDE.md)** → Section 2 (15 min)
   → Fonctionnalités des 3 webhooks

3. **[CSWEB-WEBHOOKS-GUIDE.md](CSWEB-WEBHOOKS-GUIDE.md)** → Section 6 (10 min)
   → Monitoring et métriques

**Temps total:** ~35 minutes

---

## 📊 Vue d'Ensemble des Webhooks

### 1. Breakout Webhook

**Fonction:** Exécute le processus de breakout CSPro (extraction cases → MySQL)

**Endpoint:**
```
POST /kairos/breakout-webhook.php
```

**Documentation:**
- [CSWEB-WEBHOOKS-GUIDE.md → Section 2.1](CSWEB-WEBHOOKS-GUIDE.md#21-breakout-webhook)
- [csweb-webhook/README.md → breakout-webhook.php](csweb-webhook/README.md#1-breakout-webhookphp)

---

### 2. Log Reader Webhook

**Fonction:** Lecture des fichiers logs CSWeb (ui.log, ui.dev.log, console.log)

**Endpoints:**
```
GET /kairos/log-reader-webhook.php?action=list
GET /kairos/log-reader-webhook.php?file=ui.log&lines=200
```

**Documentation:**
- [CSWEB-WEBHOOKS-GUIDE.md → Section 2.2](CSWEB-WEBHOOKS-GUIDE.md#22-log-reader-webhook)
- [csweb-webhook/README.md → log-reader-webhook.php](csweb-webhook/README.md#2-log-reader-webhookphp)

---

### 3. Dictionary Schema Webhook

**Fonction:** Gestion de la configuration des schémas MySQL pour le breakout

**Endpoints:**
```
GET /kairos/dictionary-schema-webhook.php?action=list
POST /kairos/dictionary-schema-webhook.php (register/unregister)
```

**Documentation:**
- [CSWEB-WEBHOOKS-GUIDE.md → Section 2.3](CSWEB-WEBHOOKS-GUIDE.md#23-dictionary-schema-webhook)
- [csweb-webhook/README.md → dictionary-schema-webhook.php](csweb-webhook/README.md#3-dictionary-schema-webhookphp)

---

## 🔐 Sécurité

Tous les webhooks utilisent **Bearer Token** pour l'authentification.

**Configuration:**

1. **Kairos API (.env):**
   ```bash
   CSPRO_WEBHOOK_TOKEN=votre_token_securise
   ```

2. **CSWeb Server (Apache):**
   ```bash
   SetEnv BREAKOUT_WEBHOOK_TOKEN "votre_token_securise"
   ```

**Important:** Les deux tokens DOIVENT être identiques.

**Générer un token sécurisé:**
```bash
openssl rand -base64 32
```

→ [CSWEB-WEBHOOKS-GUIDE.md → Section 5](CSWEB-WEBHOOKS-GUIDE.md#5-sécurité-et-authentification)

---

## 🆘 Support Rapide

### Erreur Fréquente #1: "Invalid token"

**Solution rapide:**
```bash
# Sur le serveur CSWeb
echo $BREAKOUT_WEBHOOK_TOKEN

# Dans Kairos .env
grep CSPRO_WEBHOOK_TOKEN .env

# Les deux doivent être identiques
```

→ [CSWEB-WEBHOOKS-GUIDE.md → Troubleshooting](CSWEB-WEBHOOKS-GUIDE.md#71-erreurs-fréquentes)

---

### Erreur Fréquente #2: "Log directory not writable"

**Solution rapide:**
```bash
sudo chown -R www-data:www-data /var/www/html/kairos/var/logs
sudo chmod 755 /var/www/html/kairos/var/logs
```

→ [CSWEB-WEBHOOKS-GUIDE.md → Troubleshooting](CSWEB-WEBHOOKS-GUIDE.md#71-erreurs-fréquentes)

---

### Erreur Fréquente #3: Connection timeout

**Solution rapide:**
```yaml
# Augmenter le timeout dans application.yml
cspro:
  webhook:
    timeout-seconds: 600  # 10 minutes
```

→ [CSWEB-WEBHOOKS-GUIDE.md → Troubleshooting](CSWEB-WEBHOOKS-GUIDE.md#71-erreurs-fréquentes)

---

## 📞 Ressources Externes

- **CSPro Documentation:** https://www.census.gov/data/software/cspro.html
- **CSWeb Documentation:** https://www.csprousers.org/help/CSWeb/
- **Spring Boot Scheduling:** https://spring.io/guides/gs/scheduling-tasks/
- **Symfony Console:** https://symfony.com/doc/current/console.html

---

**Dernière mise à jour:** Mars 2026
**Maintenance:** Équipe Kairos
