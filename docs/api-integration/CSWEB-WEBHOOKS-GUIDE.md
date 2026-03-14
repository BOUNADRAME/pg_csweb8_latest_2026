# Guide Complet des Webhooks CSWeb

> Documentation technique sur l'architecture, le déploiement et la gestion à distance des webhooks CSWeb

**Version:** 1.0
**Date:** Mars 2026
**Environnement:** CSWeb 7.7+ | PHP 8.1+ | Kairos API Spring Boot 3.5

---

## Table des Matières

1. [Architecture Globale](#1-architecture-globale)
2. [Les 3 Webhooks CSWeb](#2-les-3-webhooks-csweb)
3. [Déploiement sur le Serveur CSWeb](#3-déploiement-sur-le-serveur-csweb)
4. [Gestion à Distance depuis Kairos API](#4-gestion-à-distance-depuis-kairos-api)
5. [Sécurité et Authentification](#5-sécurité-et-authentification)
6. [Monitoring et Logs](#6-monitoring-et-logs)
7. [Troubleshooting](#7-troubleshooting)
8. [Exemples d'Utilisation](#8-exemples-dutilisation)

---

## 1. Architecture Globale

### 1.1 Vue d'Ensemble

```
┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│   Frontend UI    │         │   Kairos API     │         │   CSWeb Server   │
│  (Angular/React) │────────▶│  (Spring Boot)   │────────▶│  (PHP Symfony)   │
└──────────────────┘         └──────────────────┘         └──────────────────┘
                                      │                             │
                                      │                             │
                                      └────────── WEBHOOKS ─────────┘
                                           (Bearer Token)
```

### 1.2 Composants Principaux

| Composant | Technologie | Rôle |
|-----------|-------------|------|
| **CSWeb Server** | PHP 8.1 + Symfony | Serveur de collecte CSPro |
| **Webhooks PHP** | PHP 8.1 (standalone) | Scripts PHP sécurisés par token |
| **Kairos API** | Spring Boot 3.5 + Java 25 | API REST orchestrant les webhooks |
| **PostgreSQL** | PostgreSQL 16 | Base de données Kairos |
| **CSWeb MySQL** | MySQL 5.7+ | Base de données CSWeb |

### 1.3 Flux de Données

```
1. Frontend envoie requête POST → Kairos API (/api/admin/cspro/breakout/{dict}/trigger)
                                         ↓
2. Kairos valide JWT + ROLE_ADMIN        │
                                         ↓
3. Kairos envoie POST → Webhook CSWeb (Bearer token)
                                         ↓
4. Webhook exécute commande PHP          │
                                         ↓
5. Webhook retourne résultat JSON → Kairos API
                                         ↓
6. Kairos retourne résultat → Frontend
```

---

## 2. Les 3 Webhooks CSWeb

### 2.1 Breakout Webhook

**Fichier:** `breakout-webhook.php`
**Déploiement:** `/var/www/html/kairos/breakout-webhook.php`
**Fonction:** Exécute le processus de breakout CSPro (extraction des données cases vers MySQL)

#### Endpoints

```
POST /kairos/breakout-webhook.php
Authorization: Bearer <BREAKOUT_WEBHOOK_TOKEN>
Content-Type: application/json

Body:
{
  "dictionary": "EVAL_PRODUCTEURS_USAID"
}
```

#### Réponse (Succès)

```json
{
  "success": true,
  "dictionary": "EVAL_PRODUCTEURS_USAID",
  "exitCode": 0,
  "output": "Breakout completed successfully. 150 cases processed.",
  "error": "",
  "durationMs": 4523,
  "logFile": "EVAL_PRODUCTEURS_USAID_20260314_153045-api.log"
}
```

#### Réponse (Erreur)

```json
{
  "success": false,
  "dictionary": "EVAL_PRODUCTEURS_USAID",
  "exitCode": 1,
  "output": "ERROR: Table producteurs already exists",
  "error": "ERROR: Table producteurs already exists",
  "durationMs": 1234,
  "logFile": "EVAL_PRODUCTEURS_USAID_20260314_153045-api.log",
  "logError": "Log directory not writable: /var/www/html/kairos/var/logs"
}
```

#### Configuration Environnement

| Variable | Défaut | Description |
|----------|---------|-------------|
| `BREAKOUT_WEBHOOK_TOKEN` | `kairos_breakout_2024` | Token secret partagé avec Kairos |
| `CSWEB_ROOT` | `/var/www/html/kairos` | Chemin d'installation CSWeb |

#### Sécurité

- ✅ Validation du nom de dictionnaire (regex: `^[A-Z0-9_]+$`)
- ✅ Authentification Bearer Token avec `hash_equals()` (protection timing attacks)
- ✅ `escapeshellarg()` sur les paramètres de commande
- ✅ Timeout de 300 secondes max

---

### 2.2 Log Reader Webhook

**Fichier:** `log-reader-webhook.php`
**Déploiement:** `/var/www/html/kairos/log-reader-webhook.php`
**Fonction:** Lecture des fichiers logs CSWeb (ui.log, ui.dev.log, console.log)

#### Endpoints

**Lister les fichiers logs disponibles:**

```
GET /kairos/log-reader-webhook.php?action=list
Authorization: Bearer <BREAKOUT_WEBHOOK_TOKEN>
```

Réponse:
```json
{
  "success": true,
  "logsDir": "/var/www/html/kairos/var/logs",
  "files": [
    {
      "name": "ui.log",
      "sizeBytes": 245678,
      "lastModified": "2026-03-14T17:30:00+00:00"
    },
    {
      "name": "EVAL_PRODUCTEURS_USAID_20260314_153045-api.log",
      "sizeBytes": 8901,
      "lastModified": "2026-03-14T15:30:45+00:00"
    }
  ]
}
```

**Lire un fichier log:**

```
GET /kairos/log-reader-webhook.php?file=ui.log&lines=200
Authorization: Bearer <BREAKOUT_WEBHOOK_TOKEN>
```

Réponse:
```json
{
  "success": true,
  "file": "ui.log",
  "lines": 200,
  "content": "[2026-03-14T16:50:01.266568+00:00] app.ERROR: Failed deleting tables...\n...",
  "fileSizeBytes": 245678,
  "lastModified": "2026-03-14T17:30:00+00:00"
}
```

#### Paramètres

| Paramètre | Type | Défaut | Plage | Description |
|-----------|------|--------|-------|-------------|
| `action` | string | - | `list` | Lister les fichiers disponibles |
| `file` | string | `ui.log` | - | Nom du fichier log |
| `lines` | int | `200` | `1-5000` | Nombre de dernières lignes |

#### Sécurité

- ✅ Validation stricte du nom de fichier (interdit `/`, `\`, `..`, `.`)
- ✅ Accès limité au répertoire `var/logs/` uniquement
- ✅ Utilise `tail` pour éviter de charger de gros fichiers en mémoire
- ✅ Timeout de 30 secondes par défaut

---

### 2.3 Dictionary Schema Webhook

**Fichier:** `dictionary-schema-webhook.php`
**Déploiement:** `/var/www/html/kairos/dictionary-schema-webhook.php`
**Fonction:** Gestion de la configuration des schémas MySQL pour le breakout

#### Endpoints

**Lister tous les dictionnaires:**

```
GET /kairos/dictionary-schema-webhook.php?action=list
Authorization: Bearer <BREAKOUT_WEBHOOK_TOKEN>
```

Réponse:
```json
{
  "success": true,
  "dictionaries": [
    {
      "id": 3,
      "dictionary_name": "EVAL_PRODUCTEURS_USAID",
      "dictionary_label": "Évaluation Producteurs USAID",
      "configured": true,
      "host_name": "localhost",
      "schema_name": "kairos_dev",
      "schema_user_name": "kairos_dev"
    },
    {
      "id": 5,
      "dictionary_name": "MENAGE_2024",
      "dictionary_label": "Enquête Ménages 2024",
      "configured": false,
      "host_name": null,
      "schema_name": null,
      "schema_user_name": null
    }
  ],
  "total": 2
}
```

**Obtenir le statut d'un dictionnaire:**

```
GET /kairos/dictionary-schema-webhook.php?action=status&dictionary_id=3
Authorization: Bearer <BREAKOUT_WEBHOOK_TOKEN>
```

**Enregistrer/Mettre à jour une configuration:**

```
POST /kairos/dictionary-schema-webhook.php
Authorization: Bearer <BREAKOUT_WEBHOOK_TOKEN>
Content-Type: application/json

{
  "action": "register",
  "dictionary_id": 3,
  "host_name": "localhost",
  "schema_name": "kairos_dev",
  "schema_user_name": "kairos_dev",
  "schema_password": "kairos_dev_pwd"
}
```

Réponse:
```json
{
  "success": true,
  "message": "Schema registered for dictionary_id=3",
  "dictionary_id": 3
}
```

**Supprimer une configuration:**

```
POST /kairos/dictionary-schema-webhook.php
Authorization: Bearer <BREAKOUT_WEBHOOK_TOKEN>
Content-Type: application/json

{
  "action": "unregister",
  "dictionary_id": 3
}
```

Réponse:
```json
{
  "success": true,
  "deleted": true,
  "message": "Schema unregistered for dictionary_id=3",
  "dictionary_id": 3
}
```

#### Table `cspro_dictionaries_schema`

```sql
CREATE TABLE cspro_dictionaries_schema (
  dictionary_id INT PRIMARY KEY,
  host_name VARCHAR(255) NOT NULL,
  schema_name VARCHAR(255) NOT NULL,
  schema_user_name VARCHAR(255) NOT NULL,
  schema_password VARCHAR(255) NOT NULL,
  created_time DATETIME NOT NULL,
  modified_time DATETIME NOT NULL,
  FOREIGN KEY (dictionary_id) REFERENCES cspro_dictionaries(id)
);
```

---

## 3. Déploiement sur le Serveur CSWeb

### 3.1 Prérequis

- **Serveur CSWeb:** `http://193.203.15.16/kairos/`
- **PHP:** 8.1+ avec extensions `pdo_mysql`, `json`, `mbstring`
- **CSWeb:** Version 7.7+ installée dans `/var/www/html/kairos/`
- **Permissions:** L'utilisateur web (Apache: `www-data`) doit avoir accès en lecture à CSWeb et en écriture sur `var/logs/`

### 3.2 Installation des Webhooks

```bash
# 1. Se connecter au serveur CSWeb
ssh admin@193.203.15.16

# 2. Créer le répertoire si nécessaire
sudo mkdir -p /var/www/html/kairos

# 3. Copier les fichiers webhook
sudo cp breakout-webhook.php /var/www/html/kairos/
sudo cp log-reader-webhook.php /var/www/html/kairos/
sudo cp dictionary-schema-webhook.php /var/www/html/kairos/

# 4. Définir les permissions appropriées
sudo chown www-data:www-data /var/www/html/kairos/*-webhook.php
sudo chmod 644 /var/www/html/kairos/*-webhook.php

# 5. Vérifier que le répertoire logs est accessible
sudo chown -R www-data:www-data /var/www/html/kairos/var/logs
sudo chmod 755 /var/www/html/kairos/var/logs
```

### 3.3 Configuration Apache (si nécessaire)

```apache
<Directory /var/www/html/kairos>
    Options -Indexes +FollowSymLinks
    AllowOverride None
    Require all granted

    # Protection contre l'exécution de fichiers uploadés
    <FilesMatch "\.(php)$">
        Require all granted
    </FilesMatch>
</Directory>
```

### 3.4 Variables d'Environnement

Créer `/var/www/html/kairos/.env` (ou configurer Apache):

```bash
# Token partagé (DOIT correspondre à CSPRO_WEBHOOK_TOKEN dans Kairos)
BREAKOUT_WEBHOOK_TOKEN=kairos_breakout_2024

# Chemin CSWeb (si différent du défaut)
CSWEB_ROOT=/var/www/html/kairos
```

**Apache (méthode recommandée):**

```apache
<VirtualHost *:80>
    ServerName 193.203.15.16
    DocumentRoot /var/www/html

    SetEnv BREAKOUT_WEBHOOK_TOKEN "kairos_breakout_2024"
    SetEnv CSWEB_ROOT "/var/www/html/kairos"
</VirtualHost>
```

### 3.5 Test de Déploiement

```bash
# Test 1: Vérifier que les webhooks sont accessibles
curl http://193.203.15.16/kairos/breakout-webhook.php

# Réponse attendue (401 car pas de token):
# {"success":false,"error":"Missing or invalid Authorization header..."}

# Test 2: Tester avec un token
curl -X POST http://193.203.15.16/kairos/breakout-webhook.php \
  -H "Authorization: Bearer kairos_breakout_2024" \
  -H "Content-Type: application/json" \
  -d '{"dictionary":"EVAL_PRODUCTEURS_USAID"}'

# Test 3: Lister les logs
curl -X GET "http://193.203.15.16/kairos/log-reader-webhook.php?action=list" \
  -H "Authorization: Bearer kairos_breakout_2024"

# Test 4: Lister les dictionnaires
curl -X GET "http://193.203.15.16/kairos/dictionary-schema-webhook.php?action=list" \
  -H "Authorization: Bearer kairos_breakout_2024"
```

---

## 4. Gestion à Distance depuis Kairos API

### 4.1 Configuration Kairos API

**Fichier:** `src/main/resources/application.yml`

```yaml
cspro:
  base-url: ${CSPRO_BASE_URL:http://193.203.15.16/kairos}
  timeout-seconds: ${CSPRO_TIMEOUT:30}

  auth:
    client-id: ${CSPRO_CLIENT_ID:cspro_android}
    client-secret: ${CSPRO_CLIENT_SECRET:cspro}
    username: ${CSPRO_USERNAME:admin}
    password: ${CSPRO_PASSWORD:}
    grant-type: password

  webhook:
    url: ${CSPRO_WEBHOOK_URL:http://193.203.15.16/kairos/breakout-webhook.php}
    log-reader-url: ${CSPRO_LOG_READER_URL:http://193.203.15.16/kairos/log-reader-webhook.php}
    dictionary-schema-url: ${CSPRO_DICTIONARY_SCHEMA_URL:http://193.203.15.16/kairos/dictionary-schema-webhook.php}
    token: ${CSPRO_WEBHOOK_TOKEN:kairos_breakout_2024}
    timeout-seconds: ${CSPRO_WEBHOOK_TIMEOUT:300}

  breakout:
    default-cron: ${CSPRO_BREAKOUT_CRON:0 */10 * * * ?}  # Toutes les 10 minutes
    auto-seed-on-startup: ${CSPRO_BREAKOUT_AUTO_SEED:true}
```

**Fichier:** `.env` (production)

```bash
# CSPro Server Configuration
CSPRO_BASE_URL=http://193.203.15.16/kairos
CSPRO_USERNAME=admin
CSPRO_PASSWORD=votre_mot_de_passe_cspro

# Webhook Configuration
CSPRO_WEBHOOK_URL=http://193.203.15.16/kairos/breakout-webhook.php
CSPRO_LOG_READER_URL=http://193.203.15.16/kairos/log-reader-webhook.php
CSPRO_DICTIONARY_SCHEMA_URL=http://193.203.15.16/kairos/dictionary-schema-webhook.php
CSPRO_WEBHOOK_TOKEN=votre_token_securise_produit_par_openssl

# Breakout Scheduler
CSPRO_BREAKOUT_CRON=0 0 1 * * ?  # Tous les jours à 1h du matin
CSPRO_BREAKOUT_AUTO_SEED=true
```

### 4.2 Endpoints Kairos API (Gestion à Distance)

#### 4.2.1 Authentification

Tous les endpoints `/api/admin/cspro/**` nécessitent `ROLE_ADMIN`.

```bash
# 1. Obtenir un token JWT
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Réponse:
# {
#   "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
#   "tokenType": "Bearer",
#   "roles": ["ROLE_ADMIN"]
# }
```

#### 4.2.2 Gestion des Dictionnaires

```bash
# Lister tous les dictionnaires CSPro
GET /api/admin/cspro/breakout/dictionaries

# Synchroniser les dictionnaires en jobs scheduler
POST /api/admin/cspro/breakout/sync

# Déclencher un breakout immédiat
POST /api/admin/cspro/breakout/{dictionary}/trigger

# Obtenir le statut de tous les jobs breakout
GET /api/admin/cspro/breakout/status
```

#### 4.2.3 Gestion des Logs

```bash
# Lister les fichiers logs disponibles
GET /api/admin/cspro/logs/files

# Lire un fichier log (avec parsing Symfony)
GET /api/admin/cspro/logs?file=ui.log&lines=200&level=ERROR&search=breakout

# Lire en mode brut (sans parsing)
GET /api/admin/cspro/logs?file=ui.log&lines=100&raw=true
```

#### 4.2.4 Gestion des Schémas (Dictionary Schema)

```bash
# Lister tous les dictionnaires avec statut de configuration
GET /api/admin/cspro/schemas

# Obtenir le statut d'un dictionnaire spécifique
GET /api/admin/cspro/schemas/{dictionaryId}

# Enregistrer/Mettre à jour une configuration
POST /api/admin/cspro/schemas
Content-Type: application/json
{
  "dictionaryId": 3,
  "hostName": "localhost",
  "schemaName": "kairos_dev",
  "schemaUserName": "kairos_dev",
  "schemaPassword": "kairos_dev_pwd"
}

# Supprimer une configuration
DELETE /api/admin/cspro/schemas/{dictionaryId}
```

### 4.3 Service Java (CsProBreakoutService)

**Fichier:** `src/main/java/com/project/sentiment/service/CsProBreakoutService.java`

Fonctionnalités principales:

- 🔄 **Auto-seeding au démarrage:** Crée automatiquement les jobs scheduler pour chaque dictionnaire CSPro
- 📋 **Gestion des dictionnaires:** Liste, sync, trigger
- 📊 **Monitoring des jobs:** Statut, dernière exécution, prochaine exécution
- 📝 **Parsing des logs Symfony:** Extraction structurée (timestamp, level, channel, message, context)
- 🔧 **Gestion des schémas:** Configuration MySQL pour chaque dictionnaire

### 4.4 Scheduler Dynamique

Les jobs breakout sont gérés par le `DynamicSchedulerService`:

```java
// Job ID pattern: BREAKOUT_{DICTIONARY_NAME}
// Exemple: BREAKOUT_EVAL_PRODUCTEURS_USAID

// Structure d'un job:
SchedulerJobEntity {
  jobId: "BREAKOUT_EVAL_PRODUCTEURS_USAID",
  cronExpression: "0 0 1 * * ?",  // Tous les jours à 1h
  enabled: true,
  paramsJson: '{"dictionary":"EVAL_PRODUCTEURS_USAID"}'
}
```

#### Gestion des Jobs via API

```bash
# Lister tous les jobs
GET /api/admin/scheduler/jobs

# Détail d'un job
GET /api/admin/scheduler/jobs/BREAKOUT_EVAL_PRODUCTEURS_USAID

# Modifier le cron et activer
PATCH /api/admin/scheduler/jobs/BREAKOUT_EVAL_PRODUCTEURS_USAID
Content-Type: application/json
{
  "cronExpression": "0 30 2 * * ?",  # Tous les jours à 2h30
  "enabled": true
}

# Démarrer/Arrêter un job
POST /api/admin/scheduler/jobs/BREAKOUT_EVAL_PRODUCTEURS_USAID/start
POST /api/admin/scheduler/jobs/BREAKOUT_EVAL_PRODUCTEURS_USAID/stop

# Exécuter immédiatement
POST /api/admin/scheduler/jobs/BREAKOUT_EVAL_PRODUCTEURS_USAID/trigger
```

---

## 5. Sécurité et Authentification

### 5.1 Flux d'Authentification

```
┌──────────────┐                    ┌──────────────┐                    ┌──────────────┐
│   Frontend   │                    │  Kairos API  │                    │  CSWeb       │
└──────────────┘                    └──────────────┘                    └──────────────┘
       │                                     │                                   │
       │ POST /api/auth/login                │                                   │
       │ {username, password}                │                                   │
       ├────────────────────────────────────▶│                                   │
       │                                     │                                   │
       │◀────────────────────────────────────┤                                   │
       │  {accessToken, roles}               │                                   │
       │                                     │                                   │
       │ POST /api/admin/cspro/.../trigger   │                                   │
       │ Authorization: Bearer {accessToken} │                                   │
       ├────────────────────────────────────▶│                                   │
       │                                     │                                   │
       │                                     │ POST /kairos/breakout-webhook.php │
       │                                     │ Authorization: Bearer {WEBHOOK_TOKEN}
       │                                     ├──────────────────────────────────▶│
       │                                     │                                   │
       │                                     │◀──────────────────────────────────┤
       │                                     │  {success, exitCode, output}      │
       │◀────────────────────────────────────┤                                   │
       │  {success, exitCode, output}        │                                   │
```

### 5.2 Niveaux de Sécurité

#### Niveau 1: Frontend → Kairos API

- **Méthode:** JWT (JSON Web Token)
- **Header:** `Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...`
- **Expiration:** 24 heures (configurable via `JWT_EXPIRATION`)
- **Rôle requis:** `ROLE_ADMIN` pour tous les endpoints `/api/admin/**`

#### Niveau 2: Kairos API → Webhooks CSWeb

- **Méthode:** Bearer Token (secret partagé)
- **Header:** `Authorization: Bearer kairos_breakout_2024`
- **Validation:** `hash_equals()` (protection timing attacks)
- **Recommandation:** Utiliser un token généré aléatoirement

```bash
# Générer un token sécurisé
openssl rand -base64 32
# Exemple: kL9mP3nQ7xR2vW5zA8cF1hJ4sT6uY0eI9oD3bN7m
```

### 5.3 Bonnes Pratiques

1. **Ne JAMAIS commiter les tokens dans Git:**
   ```gitignore
   .env
   .env.local
   .env.*.local
   ```

2. **Utiliser des tokens différents par environnement:**
   - Dev: `kairos_breakout_dev_2024`
   - Prod: Token généré aléatoirement (32+ caractères)

3. **Restreindre l'accès réseau:**
   ```apache
   # Apache: Autoriser seulement Kairos API
   <Location /kairos/breakout-webhook.php>
       Require ip 10.0.0.50  # IP du serveur Kairos
   </Location>
   ```

4. **Logs d'audit:**
   - Kairos API log toutes les requêtes aux webhooks
   - Les webhooks écrivent des logs de chaque exécution

---

## 6. Monitoring et Logs

### 6.1 Logs Kairos API

**Fichier:** `./logs/application.log`

```bash
# Voir les logs en temps réel
tail -f ./logs/application.log | grep -E "Breakout|CSPRO"

# Exemples de logs:
# [INFO ] CsProBreakoutService - CSPro API returned 2 dictionaries for breakout seeding
# [INFO ] CsProBreakoutService - Created breakout job: BREAKOUT_EVAL_PRODUCTEURS_USAID (disabled by default)
# [INFO ] CsProBreakoutService - === Breakout job BREAKOUT_EVAL_PRODUCTEURS_USAID starting for dictionary EVAL_PRODUCTEURS_USAID ===
# [INFO ] CsProBreakoutService - === Breakout job BREAKOUT_EVAL_PRODUCTEURS_USAID completed: exitCode=0, duration=4523ms ===
# [ERROR] CsProBreakoutService - === Breakout job BREAKOUT_MENAGE_2024 failed: error=Table already exists ===
```

### 6.2 Logs CSWeb (via API)

**Endpoint:** `GET /api/admin/cspro/logs`

**Mode Parsé (défaut):**

```bash
curl "http://localhost:8080/api/admin/cspro/logs?file=ui.log&lines=50&level=ERROR" \
  -H "Authorization: Bearer {JWT_TOKEN}"
```

Réponse:
```json
{
  "success": true,
  "file": "ui.log",
  "lines": 50,
  "content": null,
  "entries": [
    {
      "timestamp": "2026-03-14T16:50:01.266568+00:00",
      "level": "ERROR",
      "channel": "app",
      "message": "Failed deleting tables for dictionary EVAL_PRODUCTEURS_USAID",
      "context": "{\"exception\":\"SQLSTATE[42P01]: Undefined table\"} []"
    }
  ],
  "totalEntries": 1,
  "fileSizeBytes": 245678,
  "lastModified": "2026-03-14T17:30:00+00:00"
}
```

**Mode Brut (`raw=true`):**

```bash
curl "http://localhost:8080/api/admin/cspro/logs?file=ui.log&lines=100&raw=true" \
  -H "Authorization: Bearer {JWT_TOKEN}"
```

### 6.3 Logs de Breakout (CSWeb)

Chaque exécution de breakout génère un fichier log:

**Pattern:** `{DICTIONARY}_{YYYYMMDD_HHMMSS}-api.log`
**Exemple:** `EVAL_PRODUCTEURS_USAID_20260314_153045-api.log`
**Emplacement:** `/var/www/html/kairos/var/logs/`

Contenu:
```
[2026-03-14 15:30:45] BREAKOUT dictionary=EVAL_PRODUCTEURS_USAID exitCode=0 duration=4523ms
--- OUTPUT ---
Symfony Console 5.4.X

Processing dictionary: EVAL_PRODUCTEURS_USAID
Connecting to schema: kairos_dev
Deleting existing tables...
Creating tables from dictionary schema...
Extracting cases from CSPro database...
  - 150 cases processed
  - 0 errors
Breakout completed successfully.
```

### 6.4 Métriques Scheduler

Chaque job scheduler track:

| Métrique | Type | Description |
|----------|------|-------------|
| `lastRunAt` | timestamp | Dernière exécution |
| `lastRunStatus` | enum | `SUCCESS`, `FAILED`, `RUNNING` |
| `lastRunDurationMs` | int | Durée en millisecondes |
| `nextRunAt` | timestamp | Prochaine exécution calculée (cron) |
| `lastErrorMessage` | string | Message d'erreur si échec |

Exemple:
```json
{
  "jobId": "BREAKOUT_EVAL_PRODUCTEURS_USAID",
  "cronExpression": "0 0 1 * * ?",
  "enabled": true,
  "lastRunAt": "2026-03-14T01:00:05",
  "lastRunStatus": "SUCCESS",
  "lastRunDurationMs": 4523,
  "nextRunAt": "2026-03-15T01:00:00"
}
```

---

## 7. Troubleshooting

### 7.1 Erreurs Fréquentes

#### Erreur: "Invalid token"

**Symptôme:**
```json
{"success":false,"error":"Invalid token"}
```

**Causes possibles:**
1. Token différent entre Kairos (`.env: CSPRO_WEBHOOK_TOKEN`) et CSWeb (`.env: BREAKOUT_WEBHOOK_TOKEN`)
2. Espaces ou caractères cachés dans le token
3. Token pas défini (utilise le défaut `kairos_breakout_2024`)

**Solution:**
```bash
# Sur le serveur CSWeb
echo $BREAKOUT_WEBHOOK_TOKEN

# Dans Kairos .env
grep CSPRO_WEBHOOK_TOKEN .env

# Les deux doivent être identiques
```

---

#### Erreur: "Log directory not writable"

**Symptôme:**
```json
{
  "logError": "Log directory not writable: /var/www/html/kairos/var/logs (user: www-data, uid: 33)"
}
```

**Solution:**
```bash
# Sur le serveur CSWeb
sudo chown -R www-data:www-data /var/www/html/kairos/var/logs
sudo chmod 755 /var/www/html/kairos/var/logs
```

---

#### Erreur: "Failed to start process"

**Symptôme:**
```json
{
  "success": false,
  "exitCode": -1,
  "error": "Failed to start process"
}
```

**Causes possibles:**
1. Chemin CSWeb incorrect (`CSWEB_ROOT`)
2. Permissions insuffisantes sur `bin/console`
3. PHP CLI pas installé ou pas accessible

**Solution:**
```bash
# Vérifier le chemin CSWeb
ls -la /var/www/html/kairos/bin/console

# Tester la commande manuellement
sudo -u www-data php /var/www/html/kairos/bin/console csweb:process-cases-by-dict EVAL_PRODUCTEURS_USAID

# Donner les permissions d'exécution
sudo chmod +x /var/www/html/kairos/bin/console
```

---

#### Erreur: "Dictionary not found with id: X"

**Symptôme (dictionary-schema-webhook):**
```json
{
  "success": false,
  "error": "Dictionary not found with id: 3"
}
```

**Cause:**
Le `dictionary_id` n'existe pas dans la table `cspro_dictionaries`.

**Solution:**
```bash
# Vérifier les dictionnaires disponibles
curl -X GET "http://193.203.15.16/kairos/dictionary-schema-webhook.php?action=list" \
  -H "Authorization: Bearer kairos_breakout_2024"

# Utiliser un dictionary_id existant
```

---

#### Erreur: Connection timeout

**Symptôme:**
```
java.net.SocketTimeoutException: Read timed out
```

**Causes possibles:**
1. Breakout très long (> 300s par défaut)
2. Serveur CSWeb inaccessible
3. Firewall bloque la connexion

**Solution:**
```yaml
# Augmenter le timeout dans application.yml
cspro:
  webhook:
    timeout-seconds: 600  # 10 minutes
```

---

### 7.2 Commandes de Diagnostic

```bash
# 1. Tester la connectivité Kairos → CSWeb
curl -I http://193.203.15.16/kairos/breakout-webhook.php

# 2. Vérifier les logs CSWeb
tail -f /var/www/html/kairos/var/logs/ui.log

# 3. Lister les processus PHP actifs
ps aux | grep php

# 4. Vérifier l'état du scheduler Kairos
curl http://localhost:8080/api/admin/scheduler/jobs \
  -H "Authorization: Bearer {JWT_TOKEN}"

# 5. Lire les logs Kairos
tail -f ./logs/application.log | grep "Breakout"

# 6. Tester manuellement un breakout
curl -X POST http://193.203.15.16/kairos/breakout-webhook.php \
  -H "Authorization: Bearer kairos_breakout_2024" \
  -H "Content-Type: application/json" \
  -d '{"dictionary":"EVAL_PRODUCTEURS_USAID"}'
```

---

## 8. Exemples d'Utilisation

### 8.1 Workflow Complet (Frontend → API → Webhook)

```javascript
// 1. Login
const loginResponse = await fetch('http://localhost:8080/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ username: 'admin', password: 'admin123' })
});
const { accessToken } = await loginResponse.json();

// 2. Lister les dictionnaires
const dictResponse = await fetch('http://localhost:8080/api/admin/cspro/breakout/dictionaries', {
  headers: { 'Authorization': `Bearer ${accessToken}` }
});
const dictionaries = await dictResponse.json();
// ["EVAL_PRODUCTEURS_USAID", "MENAGE_2024"]

// 3. Synchroniser en jobs
const syncResponse = await fetch('http://localhost:8080/api/admin/cspro/breakout/sync', {
  method: 'POST',
  headers: { 'Authorization': `Bearer ${accessToken}` }
});
const syncResult = await syncResponse.json();
// {total: 2, created: 0, existing: 2}

// 4. Obtenir le statut des jobs
const statusResponse = await fetch('http://localhost:8080/api/admin/cspro/breakout/status', {
  headers: { 'Authorization': `Bearer ${accessToken}` }
});
const jobs = await statusResponse.json();
// [{jobId: "BREAKOUT_EVAL_PRODUCTEURS_USAID", enabled: false, ...}, ...]

// 5. Activer un job (modifier le cron)
const jobId = 'BREAKOUT_EVAL_PRODUCTEURS_USAID';
const patchResponse = await fetch(`http://localhost:8080/api/admin/scheduler/jobs/${jobId}`, {
  method: 'PATCH',
  headers: {
    'Authorization': `Bearer ${accessToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    cronExpression: '0 0 1 * * ?',  // Tous les jours à 1h
    enabled: true
  })
});

// 6. Déclencher manuellement
const triggerResponse = await fetch(`http://localhost:8080/api/admin/cspro/breakout/${dictionaries[0]}/trigger`, {
  method: 'POST',
  headers: { 'Authorization': `Bearer ${accessToken}` }
});
const breakoutResult = await triggerResponse.json();
// {success: true, exitCode: 0, durationMs: 4523, output: "...", logFile: "..."}

// 7. Lire les logs (filtrer les erreurs)
const logsResponse = await fetch('http://localhost:8080/api/admin/cspro/logs?file=ui.log&lines=50&level=ERROR', {
  headers: { 'Authorization': `Bearer ${accessToken}` }
});
const logs = await logsResponse.json();
// {success: true, entries: [{timestamp: "...", level: "ERROR", message: "..."}], ...}
```

### 8.2 Configuration d'un Dictionnaire pour Breakout

```javascript
// 1. Lister les dictionnaires avec leur statut de configuration
const schemasResponse = await fetch('http://localhost:8080/api/admin/cspro/schemas', {
  headers: { 'Authorization': `Bearer ${accessToken}` }
});
const schemas = await schemasResponse.json();
/*
[
  {
    "id": 3,
    "dictionary_name": "EVAL_PRODUCTEURS_USAID",
    "configured": false
  }
]
*/

// 2. Configurer le schéma MySQL pour le dictionnaire
const registerResponse = await fetch('http://localhost:8080/api/admin/cspro/schemas', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${accessToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    dictionaryId: 3,
    hostName: 'localhost',
    schemaName: 'kairos_dev',
    schemaUserName: 'kairos_dev',
    schemaPassword: 'kairos_dev_pwd'
  })
});
const registerResult = await registerResponse.json();
// {success: true, message: "Schema registered for dictionary_id=3", dictionary_id: 3}

// 3. Vérifier la configuration
const statusResponse = await fetch('http://localhost:8080/api/admin/cspro/schemas/3', {
  headers: { 'Authorization': `Bearer ${accessToken}` }
});
const status = await statusResponse.json();
/*
{
  "success": true,
  "dictionary": {
    "id": 3,
    "dictionary_name": "EVAL_PRODUCTEURS_USAID",
    "configured": true,
    "host_name": "localhost",
    "schema_name": "kairos_dev",
    "schema_user_name": "kairos_dev"
  }
}
*/

// 4. Maintenant on peut lancer le breakout
const triggerResponse = await fetch('http://localhost:8080/api/admin/cspro/breakout/EVAL_PRODUCTEURS_USAID/trigger', {
  method: 'POST',
  headers: { 'Authorization': `Bearer ${accessToken}` }
});
```

### 8.3 Monitoring des Logs en Temps Réel

```javascript
// Fonction pour afficher les dernières erreurs
async function fetchRecentErrors(accessToken) {
  const response = await fetch(
    'http://localhost:8080/api/admin/cspro/logs?file=ui.log&lines=100&level=ERROR&search=breakout',
    { headers: { 'Authorization': `Bearer ${accessToken}` } }
  );
  const data = await response.json();

  if (data.success && data.entries.length > 0) {
    console.log(`🔴 ${data.entries.length} erreur(s) trouvée(s):`);
    data.entries.forEach(entry => {
      console.log(`[${entry.timestamp}] ${entry.message}`);
      if (entry.context) {
        console.log(`   Context: ${entry.context.substring(0, 100)}...`);
      }
    });
  } else {
    console.log('✅ Aucune erreur récente');
  }
}

// Polling toutes les 30 secondes
setInterval(() => fetchRecentErrors(accessToken), 30000);
```

### 8.4 Script Shell pour Administration

```bash
#!/bin/bash
# kairos-admin.sh - Script d'administration Kairos/CSWeb

API_URL="http://localhost:8080"
CSPRO_WEBHOOK_URL="http://193.203.15.16/kairos"
TOKEN=""  # JWT token

# Login
login() {
  local response=$(curl -s -X POST "${API_URL}/api/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"admin123"}')

  TOKEN=$(echo "$response" | jq -r '.accessToken')
  echo "✅ Login successful"
}

# Lister les dictionnaires
list_dictionaries() {
  curl -s "${API_URL}/api/admin/cspro/breakout/dictionaries" \
    -H "Authorization: Bearer ${TOKEN}" | jq
}

# Déclencher un breakout
trigger_breakout() {
  local dictionary=$1
  echo "🚀 Triggering breakout for: $dictionary"

  curl -s -X POST "${API_URL}/api/admin/cspro/breakout/${dictionary}/trigger" \
    -H "Authorization: Bearer ${TOKEN}" | jq
}

# Afficher les logs récents
show_logs() {
  local file=${1:-ui.log}
  local lines=${2:-50}

  curl -s "${API_URL}/api/admin/cspro/logs?file=${file}&lines=${lines}" \
    -H "Authorization: Bearer ${TOKEN}" | jq -r '.entries[] | "\(.timestamp) [\(.level)] \(.message)"'
}

# Statut des jobs
job_status() {
  curl -s "${API_URL}/api/admin/cspro/breakout/status" \
    -H "Authorization: Bearer ${TOKEN}" | jq -r '.[] | "\(.jobId): enabled=\(.enabled), lastRun=\(.lastRunAt // "never"), status=\(.lastRunStatus // "N/A")"'
}

# Main
case "$1" in
  login)
    login
    ;;
  list)
    login && list_dictionaries
    ;;
  trigger)
    login && trigger_breakout "$2"
    ;;
  logs)
    login && show_logs "$2" "$3"
    ;;
  status)
    login && job_status
    ;;
  *)
    echo "Usage: $0 {login|list|trigger <dict>|logs [file] [lines]|status}"
    exit 1
    ;;
esac
```

Utilisation:
```bash
# Rendre le script exécutable
chmod +x kairos-admin.sh

# Exemples
./kairos-admin.sh list
./kairos-admin.sh trigger EVAL_PRODUCTEURS_USAID
./kairos-admin.sh logs ui.log 100
./kairos-admin.sh status
```

---

## Annexes

### A. Expressions Cron Courantes

| Expression | Description |
|------------|-------------|
| `0 0 1 * * ?` | Tous les jours à 1h du matin |
| `0 30 2 * * ?` | Tous les jours à 2h30 |
| `0 */10 * * * ?` | Toutes les 10 minutes |
| `0 0 */6 * * ?` | Toutes les 6 heures |
| `0 0 12 * * MON-FRI` | Tous les jours de semaine à midi |
| `0 0 0 1 * ?` | Le 1er de chaque mois à minuit |

### B. Codes HTTP

| Code | Signification |
|------|---------------|
| `200 OK` | Succès |
| `400 Bad Request` | Paramètre invalide (ex: dictionary name, lines hors limites) |
| `401 Unauthorized` | Token manquant, invalide ou expiré |
| `403 Forbidden` | Rôle insuffisant (ADMIN requis) |
| `404 Not Found` | Ressource non trouvée (job, dictionary, log file) |
| `405 Method Not Allowed` | Mauvaise méthode HTTP (ex: GET au lieu de POST) |
| `500 Internal Server Error` | Erreur serveur (webhook injoignable, commande échouée) |

### C. Structure des Tables

#### `cspro_dictionaries` (CSWeb MySQL)

```sql
CREATE TABLE cspro_dictionaries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  dictionary_name VARCHAR(255) NOT NULL UNIQUE,
  dictionary_label VARCHAR(255),
  created_time DATETIME NOT NULL,
  modified_time DATETIME NOT NULL
);
```

#### `cspro_dictionaries_schema` (CSWeb MySQL)

```sql
CREATE TABLE cspro_dictionaries_schema (
  dictionary_id INT PRIMARY KEY,
  host_name VARCHAR(255) NOT NULL,
  schema_name VARCHAR(255) NOT NULL,
  schema_user_name VARCHAR(255) NOT NULL,
  schema_password VARCHAR(255) NOT NULL,
  created_time DATETIME NOT NULL,
  modified_time DATETIME NOT NULL,
  FOREIGN KEY (dictionary_id) REFERENCES cspro_dictionaries(id) ON DELETE CASCADE
);
```

#### `scheduler_jobs` (Kairos PostgreSQL - schema `app`)

```sql
CREATE TABLE app.scheduler_jobs (
  job_id VARCHAR(255) PRIMARY KEY,
  cron_expression VARCHAR(255) NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT false,
  params_json TEXT,
  last_run_at TIMESTAMP,
  last_run_status VARCHAR(50),
  last_run_duration_ms INTEGER,
  next_run_at TIMESTAMP,
  last_error_message TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

### D. Références

- **CSPro Documentation:** https://www.census.gov/data/software/cspro.html
- **CSWeb Documentation:** https://www.csprousers.org/help/CSWeb/
- **Spring Boot Scheduling:** https://spring.io/guides/gs/scheduling-tasks/
- **Symfony Console Commands:** https://symfony.com/doc/current/console.html
- **Cron Expression Generator:** https://crontab.guru/

---

## Conclusion

Ce guide couvre l'ensemble de l'architecture, du déploiement et de la gestion à distance des webhooks CSWeb. Les points clés à retenir:

✅ **3 webhooks PHP** déployés sur le serveur CSWeb (`breakout`, `log-reader`, `dictionary-schema`)
✅ **Sécurité par Bearer Token** partagé entre Kairos et CSWeb
✅ **Gestion centralisée** via Kairos API (REST + JWT)
✅ **Scheduler dynamique** pour automatiser les breakouts
✅ **Monitoring complet** via logs parsés et métriques
✅ **Architecture découplée** permettant l'évolution indépendante des composants

Pour toute question ou problème, consultez la section [Troubleshooting](#7-troubleshooting) ou les logs détaillés.

---

**Auteurs:** Équipe Kairos
**Dernière mise à jour:** Mars 2026
**Version:** 1.0
