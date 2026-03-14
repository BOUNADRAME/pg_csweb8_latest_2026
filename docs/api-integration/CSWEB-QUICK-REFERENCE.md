# CSWeb Webhooks - Référence Rapide

> Commandes et endpoints essentiels pour la gestion des webhooks CSWeb

## 🔐 Authentification

### Kairos API (JWT)

```bash
# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Réponse: {"accessToken":"eyJ...","tokenType":"Bearer","roles":["ROLE_ADMIN"]}
```

Utiliser ensuite: `Authorization: Bearer eyJ...`

---

## 📋 Dictionnaires CSPro

### Lister les dictionnaires

```bash
# Via Kairos API
curl http://localhost:8080/api/admin/cspro/breakout/dictionaries \
  -H "Authorization: Bearer {JWT_TOKEN}"

# Direct CSWeb API
curl http://193.203.15.16/kairos/api/dictionaries/names \
  -H "Authorization: Bearer {CSPRO_TOKEN}"
```

### Synchroniser en jobs scheduler

```bash
curl -X POST http://localhost:8080/api/admin/cspro/breakout/sync \
  -H "Authorization: Bearer {JWT_TOKEN}"

# Réponse: {"total":2,"created":1,"existing":1}
```

---

## 🚀 Breakout

### Déclencher un breakout immédiat

```bash
# Via Kairos API (recommandé)
curl -X POST http://localhost:8080/api/admin/cspro/breakout/EVAL_PRODUCTEURS_USAID/trigger \
  -H "Authorization: Bearer {JWT_TOKEN}"

# Direct webhook CSWeb
curl -X POST http://193.203.15.16/kairos/breakout-webhook.php \
  -H "Authorization: Bearer kairos_breakout_2024" \
  -H "Content-Type: application/json" \
  -d '{"dictionary":"EVAL_PRODUCTEURS_USAID"}'
```

### Statut des jobs breakout

```bash
curl http://localhost:8080/api/admin/cspro/breakout/status \
  -H "Authorization: Bearer {JWT_TOKEN}"

# Réponse:
# [
#   {
#     "jobId": "BREAKOUT_EVAL_PRODUCTEURS_USAID",
#     "cronExpression": "0 0 1 * * ?",
#     "enabled": true,
#     "lastRunAt": "2026-03-14T01:00:05",
#     "lastRunStatus": "SUCCESS",
#     "lastRunDurationMs": 4523,
#     "nextRunAt": "2026-03-15T01:00:00"
#   }
# ]
```

---

## 📊 Scheduler (Gestion des Jobs)

### Lister tous les jobs

```bash
curl http://localhost:8080/api/admin/scheduler/jobs \
  -H "Authorization: Bearer {JWT_TOKEN}"
```

### Détail d'un job

```bash
curl http://localhost:8080/api/admin/scheduler/jobs/BREAKOUT_EVAL_PRODUCTEURS_USAID \
  -H "Authorization: Bearer {JWT_TOKEN}"
```

### Modifier un job (activer + changer cron)

```bash
curl -X PATCH http://localhost:8080/api/admin/scheduler/jobs/BREAKOUT_EVAL_PRODUCTEURS_USAID \
  -H "Authorization: Bearer {JWT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "cronExpression": "0 0 1 * * ?",
    "enabled": true
  }'
```

### Démarrer/Arrêter un job

```bash
# Démarrer
curl -X POST http://localhost:8080/api/admin/scheduler/jobs/BREAKOUT_EVAL_PRODUCTEURS_USAID/start \
  -H "Authorization: Bearer {JWT_TOKEN}"

# Arrêter
curl -X POST http://localhost:8080/api/admin/scheduler/jobs/BREAKOUT_EVAL_PRODUCTEURS_USAID/stop \
  -H "Authorization: Bearer {JWT_TOKEN}"
```

### Exécuter immédiatement (trigger)

```bash
curl -X POST http://localhost:8080/api/admin/scheduler/jobs/BREAKOUT_EVAL_PRODUCTEURS_USAID/trigger \
  -H "Authorization: Bearer {JWT_TOKEN}"
```

---

## 📝 Logs CSWeb

### Lister les fichiers logs disponibles

```bash
# Via Kairos API
curl http://localhost:8080/api/admin/cspro/logs/files \
  -H "Authorization: Bearer {JWT_TOKEN}"

# Direct webhook
curl "http://193.203.15.16/kairos/log-reader-webhook.php?action=list" \
  -H "Authorization: Bearer kairos_breakout_2024"
```

### Lire un fichier log (mode parsé)

```bash
# Dernières 200 lignes
curl "http://localhost:8080/api/admin/cspro/logs?file=ui.log&lines=200" \
  -H "Authorization: Bearer {JWT_TOKEN}"

# Filtrer par niveau (ERROR, WARNING, INFO, DEBUG)
curl "http://localhost:8080/api/admin/cspro/logs?file=ui.log&lines=100&level=ERROR" \
  -H "Authorization: Bearer {JWT_TOKEN}"

# Recherche texte libre
curl "http://localhost:8080/api/admin/cspro/logs?file=ui.log&lines=200&search=breakout" \
  -H "Authorization: Bearer {JWT_TOKEN}"

# Combiner filtres
curl "http://localhost:8080/api/admin/cspro/logs?file=ui.log&lines=100&level=ERROR&search=EVAL_PRODUCTEURS" \
  -H "Authorization: Bearer {JWT_TOKEN}"
```

### Lire en mode brut (sans parsing)

```bash
curl "http://localhost:8080/api/admin/cspro/logs?file=ui.log&lines=100&raw=true" \
  -H "Authorization: Bearer {JWT_TOKEN}"
```

---

## 🗄️ Schémas Dictionnaires

### Lister tous les dictionnaires avec statut

```bash
# Via Kairos API
curl http://localhost:8080/api/admin/cspro/schemas \
  -H "Authorization: Bearer {JWT_TOKEN}"

# Direct webhook
curl "http://193.203.15.16/kairos/dictionary-schema-webhook.php?action=list" \
  -H "Authorization: Bearer kairos_breakout_2024"
```

### Statut d'un dictionnaire spécifique

```bash
# Via Kairos API
curl http://localhost:8080/api/admin/cspro/schemas/3 \
  -H "Authorization: Bearer {JWT_TOKEN}"

# Direct webhook
curl "http://193.203.15.16/kairos/dictionary-schema-webhook.php?action=status&dictionary_id=3" \
  -H "Authorization: Bearer kairos_breakout_2024"
```

### Enregistrer/Mettre à jour une configuration

```bash
# Via Kairos API
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

# Direct webhook
curl -X POST http://193.203.15.16/kairos/dictionary-schema-webhook.php \
  -H "Authorization: Bearer kairos_breakout_2024" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "register",
    "dictionary_id": 3,
    "host_name": "localhost",
    "schema_name": "kairos_dev",
    "schema_user_name": "kairos_dev",
    "schema_password": "kairos_dev_pwd"
  }'
```

### Supprimer une configuration

```bash
# Via Kairos API
curl -X DELETE http://localhost:8080/api/admin/cspro/schemas/3 \
  -H "Authorization: Bearer {JWT_TOKEN}"

# Direct webhook
curl -X POST http://193.203.15.16/kairos/dictionary-schema-webhook.php \
  -H "Authorization: Bearer kairos_breakout_2024" \
  -H "Content-Type: application/json" \
  -d '{"action":"unregister","dictionary_id":3}'
```

---

## 🛠️ Diagnostic & Maintenance

### Tester la connectivité vers CSWeb

```bash
# Ping webhook breakout
curl -I http://193.203.15.16/kairos/breakout-webhook.php

# Réponse attendue (sans token): 401 Unauthorized
```

### Vérifier les logs Kairos

```bash
# Logs en temps réel
tail -f ./logs/application.log | grep -E "Breakout|CSPRO"

# Dernières erreurs
tail -1000 ./logs/application.log | grep ERROR
```

### Vérifier les logs CSWeb (serveur)

```bash
# SSH vers CSWeb
ssh admin@193.203.15.16

# Logs Symfony
tail -f /var/www/html/kairos/var/logs/ui.log

# Logs de breakout (API)
ls -lht /var/www/html/kairos/var/logs/*-api.log | head -10
tail -f /var/www/html/kairos/var/logs/EVAL_PRODUCTEURS_USAID_*-api.log
```

### Exécuter manuellement une commande breakout

```bash
# SSH vers CSWeb
ssh admin@193.203.15.16

# Exécuter en tant que www-data (utilisateur web)
sudo -u www-data php /var/www/html/kairos/bin/console csweb:process-cases-by-dict EVAL_PRODUCTEURS_USAID

# Vérifier les processus PHP en cours
ps aux | grep php | grep console
```

---

## 📋 Expressions Cron Courantes

| Expression | Description |
|------------|-------------|
| `0 0 1 * * ?` | Tous les jours à 1h du matin |
| `0 30 2 * * ?` | Tous les jours à 2h30 |
| `0 */10 * * * ?` | Toutes les 10 minutes |
| `0 0 */6 * * ?` | Toutes les 6 heures |
| `0 0 12 * * MON-FRI` | Jours de semaine à midi |
| `0 0 0 1 * ?` | 1er de chaque mois à minuit |

---

## 🔧 Configuration

### Variables d'environnement Kairos (.env)

```bash
# CSPro Server
CSPRO_BASE_URL=http://193.203.15.16/kairos
CSPRO_USERNAME=admin
CSPRO_PASSWORD=votre_mot_de_passe

# Webhooks
CSPRO_WEBHOOK_URL=http://193.203.15.16/kairos/breakout-webhook.php
CSPRO_LOG_READER_URL=http://193.203.15.16/kairos/log-reader-webhook.php
CSPRO_DICTIONARY_SCHEMA_URL=http://193.203.15.16/kairos/dictionary-schema-webhook.php
CSPRO_WEBHOOK_TOKEN=votre_token_securise

# Scheduler
CSPRO_BREAKOUT_CRON=0 0 1 * * ?
CSPRO_BREAKOUT_AUTO_SEED=true
```

### Variables d'environnement CSWeb (Apache)

```apache
SetEnv BREAKOUT_WEBHOOK_TOKEN "votre_token_securise"
SetEnv CSWEB_ROOT "/var/www/html/kairos"
```

---

## 🚨 Codes d'Erreur Fréquents

| Code HTTP | Erreur | Cause Probable | Solution |
|-----------|--------|----------------|----------|
| `401` | Invalid token | Token différent entre Kairos et CSWeb | Vérifier `CSPRO_WEBHOOK_TOKEN` et `BREAKOUT_WEBHOOK_TOKEN` |
| `400` | Invalid dictionary name | Nom contient caractères invalides | Utiliser uniquement `[A-Z0-9_]` |
| `404` | Log file not found | Fichier n'existe pas | Lister les fichiers avec `?action=list` |
| `500` | Failed to start process | Permissions ou chemin incorrect | Vérifier permissions et `CSWEB_ROOT` |
| `500` | exitCode != 0 | Erreur lors du breakout | Consulter `output` et fichier log généré |

---

## 📖 Documentation Complète

Pour plus de détails:
- **[Guide Complet CSWeb Webhooks](./CSWEB-WEBHOOKS-GUIDE.md)** - Architecture, déploiement, troubleshooting
- **[README Webhooks](./csweb-webhook/README.md)** - Scripts PHP individuels
- **[API CSPro Breakout](./api-cspro-breakout.md)** - Référence API frontend

---

## 🎯 Workflow Typique

```bash
# 1. Login
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}' | jq -r '.accessToken')

# 2. Lister les dictionnaires
curl -s http://localhost:8080/api/admin/cspro/breakout/dictionaries \
  -H "Authorization: Bearer $TOKEN" | jq

# 3. Synchroniser en jobs
curl -s -X POST http://localhost:8080/api/admin/cspro/breakout/sync \
  -H "Authorization: Bearer $TOKEN" | jq

# 4. Configurer un schéma (si pas encore fait)
curl -s -X POST http://localhost:8080/api/admin/cspro/schemas \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"dictionaryId":3,"hostName":"localhost","schemaName":"kairos_dev","schemaUserName":"kairos_dev","schemaPassword":"kairos_dev_pwd"}' | jq

# 5. Activer le job automatique
curl -s -X PATCH http://localhost:8080/api/admin/scheduler/jobs/BREAKOUT_EVAL_PRODUCTEURS_USAID \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"cronExpression":"0 0 1 * * ?","enabled":true}' | jq

# 6. Déclencher manuellement (test)
curl -s -X POST http://localhost:8080/api/admin/cspro/breakout/EVAL_PRODUCTEURS_USAID/trigger \
  -H "Authorization: Bearer $TOKEN" | jq

# 7. Vérifier les logs (erreurs uniquement)
curl -s "http://localhost:8080/api/admin/cspro/logs?file=ui.log&lines=100&level=ERROR" \
  -H "Authorization: Bearer $TOKEN" | jq -r '.entries[]? | "\(.timestamp) [\(.level)] \(.message)"'
```

---

**Dernière mise à jour:** Mars 2026
