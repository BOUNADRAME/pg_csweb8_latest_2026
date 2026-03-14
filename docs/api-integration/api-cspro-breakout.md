# API CSPro Breakout & Logs — Reference Frontend

> Base URL : `http://localhost:8080` (dev) | `http://193.203.15.16:8080` (prod)

---

## 1. Authentification JWT

Tous les endpoints `/api/admin/**` requierent `ROLE_ADMIN`.

### Obtenir un token

```
POST /api/auth/login
Content-Type: application/json

{ "username": "admin", "password": "..." }
```

Reponse :

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
  "tokenType": "Bearer",
  "roles": ["ROLE_ADMIN"]
}
```

### Utiliser le token

Ajouter le header sur chaque requete :

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

### Renouveler le token

```
POST /api/auth/refresh
Authorization: Bearer <token-valide>
```

---

## 2. Endpoints Breakout (5)

### 2.1 Lister les dictionnaires CSPro

```
GET /api/admin/cspro/breakout/dictionaries
```

Reponse : `["EVAL_PRODUCTEURS_USAID", "MENAGE_2024"]`

### 2.2 Synchroniser dictionnaires en jobs breakout

```
POST /api/admin/cspro/breakout/sync
```

Reponse :

```json
{ "total": 3, "created": 1, "existing": 2 }
```

### 2.3 Declencher un breakout (immediat)

```
POST /api/admin/cspro/breakout/{dictionary}/trigger
```

Reponse :

```json
{
  "success": true,
  "dictionary": "EVAL_PRODUCTEURS_USAID",
  "exitCode": 0,
  "output": "Breakout completed successfully",
  "error": "",
  "durationMs": 4523
}
```

### 2.4 Statut des jobs breakout

```
GET /api/admin/cspro/breakout/status
```

Reponse :

```json
[
  {
    "jobId": "BREAKOUT_EVAL_PRODUCTEURS_USAID",
    "cronExpression": "0 0 1 * * ?",
    "enabled": true,
    "params": { "dictionary": "EVAL_PRODUCTEURS_USAID" },
    "lastRunAt": "2026-02-23T01:00:05",
    "lastRunStatus": "SUCCESS",
    "lastRunDurationMs": 4523,
    "nextRunAt": "2026-02-24T01:00:00",
    "createdAt": "2026-02-20T10:00:00",
    "updatedAt": "2026-02-23T01:00:05"
  }
]
```

### 2.5 Lister les fichiers logs disponibles

```
GET /api/admin/cspro/logs/files
```

Reponse :

```json
[
  { "name": "ui.log", "sizeBytes": 245678, "lastModified": "2026-02-23T17:30:00+00:00" },
  { "name": "ui.dev.log", "sizeBytes": 1024567, "lastModified": "2026-02-23T17:30:00+00:00" },
  { "name": "console.log", "sizeBytes": 8901, "lastModified": "2026-02-22T10:00:00+00:00" }
]
```

### 2.6 Lire les logs CSWeb

```
GET /api/admin/cspro/logs?file=ui.log&lines=50&level=ERROR&search=breakout
```

| Parametre | Type | Defaut | Description |
|-----------|------|--------|-------------|
| `file` | string | `ui.log` | Fichier log (`ui.log` ou `ui.dev.log`) |
| `lines` | int | `200` | Nombre de lignes (1-5000) |
| `level` | string | _(tous)_ | Filtre par niveau : `ERROR`, `CRITICAL`, `WARNING`, `INFO`, `DEBUG` |
| `search` | string | _(aucun)_ | Recherche texte libre dans message et context |
| `raw` | boolean | `false` | Si `true`, retourne le contenu brut dans `content` sans parsing |

**Reponse (mode parse, defaut) :**

```json
{
  "success": true,
  "file": "ui.log",
  "lines": 50,
  "content": null,
  "entries": [
    {
      "timestamp": "2026-02-23T16:50:01.266568+00:00",
      "level": "ERROR",
      "channel": "app",
      "message": "Failed deleting tables for dictionary EVAL_PRODUCTEURS_USAID",
      "context": "{\"exception\":\"SQLSTATE[42P01]\"} []"
    }
  ],
  "totalEntries": 1,
  "fileSizeBytes": 245678,
  "lastModified": "2026-02-23T17:30:00+00:00",
  "error": ""
}
```

**Reponse (mode raw, `raw=true`) :**

```json
{
  "success": true,
  "file": "ui.log",
  "lines": 50,
  "content": "[2026-02-23T16:50:01.266568+00:00] app.ERROR: Failed deleting...\n...",
  "entries": null,
  "totalEntries": 0,
  "fileSizeBytes": 245678,
  "lastModified": "2026-02-23T17:30:00+00:00",
  "error": ""
}
```

---

## 3. Endpoints Scheduler (utiles pour les jobs BREAKOUT_*)

Les jobs breakout sont geres par le scheduler dynamique. Prefixe des jobs : `BREAKOUT_`.

### 3.1 Lister tous les jobs

```
GET /api/admin/scheduler/jobs
```

### 3.2 Detail d'un job

```
GET /api/admin/scheduler/jobs/{jobId}
```

Exemple : `GET /api/admin/scheduler/jobs/BREAKOUT_EVAL_PRODUCTEURS_USAID`

### 3.3 Modifier un job (cron, enabled, params)

```
PATCH /api/admin/scheduler/jobs/{jobId}
Content-Type: application/json

{ "cronExpression": "0 30 2 * * ?", "enabled": true }
```

### 3.4 Demarrer / Arreter un job

```
POST /api/admin/scheduler/jobs/{jobId}/start
POST /api/admin/scheduler/jobs/{jobId}/stop
```

### 3.5 Executer un job immediatement

```
POST /api/admin/scheduler/jobs/{jobId}/trigger
```

---

## 4. Format des log entries

Chaque entree de log Symfony est parsee avec la regex :

```
^\[(.+?)\]\s+(\w+)\.(\w+):\s+(.*)$
```

| Champ | Type | Description |
|-------|------|-------------|
| `timestamp` | string | ISO 8601 avec timezone (`2026-02-23T16:50:01.266568+00:00`) |
| `level` | string | Niveau : `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL` |
| `channel` | string | Canal Symfony : `app`, `console`, `doctrine`, etc. |
| `message` | string | Message principal (sans le bloc JSON context) |
| `context` | string \| null | Bloc JSON `{...} []` et/ou stacktrace (lignes concatenees) |

Les lignes qui ne matchent pas la regex (stacktrace, output multi-ligne) sont concatenees au champ `context` de l'entree precedente.

---

## 5. Workflow d'integration frontend

```
1. POST /api/auth/login              -> obtenir accessToken
2. GET  /breakout/dictionaries       -> afficher la liste des dictionnaires
3. POST /breakout/sync               -> creer les jobs manquants
4. GET  /breakout/status             -> afficher le statut de chaque job
5. PATCH /scheduler/jobs/{id}        -> activer/configurer le cron d'un job
6. POST /breakout/{dict}/trigger     -> lancer un breakout a la demande
7. GET  /cspro/logs?lines=50         -> afficher les logs parses
8. GET  /cspro/logs?level=ERROR      -> filtrer les erreurs
9. GET  /cspro/logs?search=EVAL      -> rechercher dans les logs
```

### Gestion des erreurs

Tous les endpoints retournent un HTTP standard :

| Code | Signification |
|------|---------------|
| `200` | Succes |
| `400` | Parametre invalide (ex: `lines` hors limites, dictionnaire invalide) |
| `401` | Token manquant ou expire |
| `403` | Role insuffisant (ADMIN requis) |
| `404` | Ressource non trouvee (job inexistant) |
| `500` | Erreur serveur (webhook/API CSPro injoignable) |
