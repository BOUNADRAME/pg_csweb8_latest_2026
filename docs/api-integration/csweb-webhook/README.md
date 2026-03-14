# CSWeb Webhooks - Scripts PHP

> Scripts PHP pour l'intégration CSWeb ↔ Kairos API

**Déploiement:** `/var/www/html/kairos/` sur le serveur CSWeb (`http://193.203.15.16/kairos/`)

## 📁 Fichiers

### 1. `breakout-webhook.php`

Exécute le processus de breakout CSPro (extraction des données cases vers MySQL).

**Endpoint:**
```
POST /kairos/breakout-webhook.php
Authorization: Bearer <BREAKOUT_WEBHOOK_TOKEN>
Content-Type: application/json

{"dictionary": "EVAL_PRODUCTEURS_USAID"}
```

**Commande exécutée:**
```bash
php /var/www/html/kairos/bin/console csweb:process-cases-by-dict EVAL_PRODUCTEURS_USAID
```

**Réponse:**
```json
{
  "success": true,
  "dictionary": "EVAL_PRODUCTEURS_USAID",
  "exitCode": 0,
  "output": "Breakout completed successfully. 150 cases processed.",
  "durationMs": 4523,
  "logFile": "EVAL_PRODUCTEURS_USAID_20260314_153045-api.log"
}
```

**Variables d'environnement:**
- `BREAKOUT_WEBHOOK_TOKEN` (défaut: `kairos_breakout_2024`)
- `CSWEB_ROOT` (défaut: `/var/www/html/kairos`)

---

### 2. `log-reader-webhook.php`

Lecture des fichiers logs CSWeb (`ui.log`, `ui.dev.log`, `console.log`, etc.).

**Endpoints:**

```bash
# Lister les fichiers logs disponibles
GET /kairos/log-reader-webhook.php?action=list

# Lire un fichier log
GET /kairos/log-reader-webhook.php?file=ui.log&lines=200
```

**Paramètres:**
- `action` (string): `list` pour lister les fichiers
- `file` (string, défaut: `ui.log`): Nom du fichier log
- `lines` (int, défaut: `200`, plage: `1-5000`): Nombre de lignes

**Réponse (list):**
```json
{
  "success": true,
  "logsDir": "/var/www/html/kairos/var/logs",
  "files": [
    {
      "name": "ui.log",
      "sizeBytes": 245678,
      "lastModified": "2026-03-14T17:30:00+00:00"
    }
  ]
}
```

**Réponse (file):**
```json
{
  "success": true,
  "file": "ui.log",
  "lines": 200,
  "content": "[2026-03-14T16:50:01.266568+00:00] app.ERROR: Failed...\n...",
  "fileSizeBytes": 245678,
  "lastModified": "2026-03-14T17:30:00+00:00"
}
```

---

### 3. `dictionary-schema-webhook.php`

Gestion de la configuration des schémas MySQL pour le breakout (table `cspro_dictionaries_schema`).

**Endpoints:**

```bash
# Lister tous les dictionnaires avec leur statut de configuration
GET /kairos/dictionary-schema-webhook.php?action=list

# Obtenir le statut d'un dictionnaire spécifique
GET /kairos/dictionary-schema-webhook.php?action=status&dictionary_id=3

# Enregistrer/Mettre à jour une configuration
POST /kairos/dictionary-schema-webhook.php
Content-Type: application/json
{
  "action": "register",
  "dictionary_id": 3,
  "host_name": "localhost",
  "schema_name": "kairos_dev",
  "schema_user_name": "kairos_dev",
  "schema_password": "kairos_dev_pwd"
}

# Supprimer une configuration
POST /kairos/dictionary-schema-webhook.php
Content-Type: application/json
{
  "action": "unregister",
  "dictionary_id": 3
}
```

**Réponse (list):**
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
    }
  ],
  "total": 1
}
```

---

## 🔒 Sécurité

Tous les webhooks utilisent **Bearer Token** pour l'authentification:

```
Authorization: Bearer <BREAKOUT_WEBHOOK_TOKEN>
```

**Validation:**
- `hash_equals()` (protection contre timing attacks)
- Token par défaut: `kairos_breakout_2024` (**À CHANGER EN PRODUCTION**)

**Recommandation:** Générer un token sécurisé:
```bash
openssl rand -base64 32
```

---

## 🚀 Déploiement

### Installation

```bash
# 1. Se connecter au serveur CSWeb
ssh admin@193.203.15.16

# 2. Copier les fichiers
sudo cp breakout-webhook.php /var/www/html/kairos/
sudo cp log-reader-webhook.php /var/www/html/kairos/
sudo cp dictionary-schema-webhook.php /var/www/html/kairos/

# 3. Définir les permissions
sudo chown www-data:www-data /var/www/html/kairos/*-webhook.php
sudo chmod 644 /var/www/html/kairos/*-webhook.php

# 4. Vérifier le répertoire logs
sudo chown -R www-data:www-data /var/www/html/kairos/var/logs
sudo chmod 755 /var/www/html/kairos/var/logs
```

### Configuration Apache

Créer `/var/www/html/kairos/.htaccess` (ou configurer dans VirtualHost):

```apache
# Protection contre l'exécution de fichiers uploadés
<FilesMatch "\.(php)$">
    Require all granted
</FilesMatch>

# Variables d'environnement
SetEnv BREAKOUT_WEBHOOK_TOKEN "votre_token_securise"
SetEnv CSWEB_ROOT "/var/www/html/kairos"
```

**OU** dans le VirtualHost:

```apache
<VirtualHost *:80>
    ServerName 193.203.15.16
    DocumentRoot /var/www/html

    SetEnv BREAKOUT_WEBHOOK_TOKEN "votre_token_securise"
    SetEnv CSWEB_ROOT "/var/www/html/kairos"

    # Restreindre l'accès (optionnel)
    <Location /kairos/breakout-webhook.php>
        Require ip 10.0.0.50  # IP du serveur Kairos
    </Location>
</VirtualHost>
```

### Test

```bash
# Test 1: Breakout webhook
curl -X POST http://193.203.15.16/kairos/breakout-webhook.php \
  -H "Authorization: Bearer kairos_breakout_2024" \
  -H "Content-Type: application/json" \
  -d '{"dictionary":"EVAL_PRODUCTEURS_USAID"}'

# Test 2: Log reader webhook (list)
curl -X GET "http://193.203.15.16/kairos/log-reader-webhook.php?action=list" \
  -H "Authorization: Bearer kairos_breakout_2024"

# Test 3: Log reader webhook (file)
curl -X GET "http://193.203.15.16/kairos/log-reader-webhook.php?file=ui.log&lines=50" \
  -H "Authorization: Bearer kairos_breakout_2024"

# Test 4: Dictionary schema webhook (list)
curl -X GET "http://193.203.15.16/kairos/dictionary-schema-webhook.php?action=list" \
  -H "Authorization: Bearer kairos_breakout_2024"
```

---

## 📊 Utilisation depuis Kairos API

Les webhooks sont appelés automatiquement via Kairos API. Configuration dans `application.yml`:

```yaml
cspro:
  webhook:
    url: http://193.203.15.16/kairos/breakout-webhook.php
    log-reader-url: http://193.203.15.16/kairos/log-reader-webhook.php
    dictionary-schema-url: http://193.203.15.16/kairos/dictionary-schema-webhook.php
    token: ${CSPRO_WEBHOOK_TOKEN:kairos_breakout_2024}
    timeout-seconds: 300
```

**Endpoints Kairos API (nécessitent JWT + ROLE_ADMIN):**

```bash
# Déclencher un breakout
POST /api/admin/cspro/breakout/{dictionary}/trigger

# Lire les logs CSWeb (avec parsing Symfony)
GET /api/admin/cspro/logs?file=ui.log&lines=200&level=ERROR

# Lister les fichiers logs
GET /api/admin/cspro/logs/files

# Gérer les schémas
GET /api/admin/cspro/schemas
POST /api/admin/cspro/schemas
DELETE /api/admin/cspro/schemas/{dictionaryId}
```

---

## 📖 Documentation Complète

Voir: **[`../CSWEB-WEBHOOKS-GUIDE.md`](../CSWEB-WEBHOOKS-GUIDE.md)**

Le guide complet couvre:
- Architecture globale
- Déploiement détaillé
- Gestion à distance depuis Kairos API
- Sécurité et authentification
- Monitoring et logs
- Troubleshooting
- Exemples d'utilisation

---

## 🛠️ Troubleshooting

### Erreur: "Invalid token"

```bash
# Vérifier le token sur le serveur CSWeb
echo $BREAKOUT_WEBHOOK_TOKEN

# Vérifier le token dans Kairos .env
grep CSPRO_WEBHOOK_TOKEN .env

# Les deux doivent être identiques
```

### Erreur: "Log directory not writable"

```bash
sudo chown -R www-data:www-data /var/www/html/kairos/var/logs
sudo chmod 755 /var/www/html/kairos/var/logs
```

### Erreur: "Failed to start process"

```bash
# Vérifier le chemin CSWeb
ls -la /var/www/html/kairos/bin/console

# Tester manuellement
sudo -u www-data php /var/www/html/kairos/bin/console csweb:process-cases-by-dict EVAL_PRODUCTEURS_USAID
```

---

**Dernière mise à jour:** Mars 2026
