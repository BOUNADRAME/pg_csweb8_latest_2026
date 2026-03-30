# Tuto : Configurer un Breakout Distant vers un autre projet Docker

## Contexte

CSWeb tourne dans ses propres containers Docker (`csweb-app`, `csweb-mysql-metadata`).
Quand la base de données cible (PostgreSQL, MySQL, SQL Server) tourne dans **un autre projet Docker**, les deux réseaux sont isolés — `localhost` ne fonctionne pas depuis l'intérieur d'un container.

---

## Étape 1 — Identifier le port exposé de la base cible

Dans le `docker-compose.yml` du projet cible, repère le mapping de port :

```yaml
ports:
  - "5433:5432"   # hôte:container
```

Ici, la base PostgreSQL est accessible depuis la machine hôte sur le port **5433**.

---

## Étape 2 — Vérifier que la base cible tourne

```bash
docker ps | grep <nom_container>
```

Exemple :
```
kairos-florida-postgres   Up 4 hours (healthy)   0.0.0.0:5433->5432/tcp
```

---

## Étape 3 — Choisir le bon hostname

| Situation | Hostname | Port |
|-----------|----------|------|
| DB dans un réseau Docker différent (cas habituel) | `host.docker.internal` | port exposé sur l'hôte (ex: `5433`) |
| DB dans le même réseau Docker que csweb | nom du container (ex: `kairos-florida-postgres`) | port interne (`5432`) |
| DB sur machine distante | IP ou hostname réseau | port configuré |

> **Sur macOS avec Docker Desktop**, `host.docker.internal` résout automatiquement vers la machine hôte — c'est la méthode recommandée.

---

## Étape 4 — Remplir le formulaire CSWeb "Add Configuration"

| Champ | Valeur |
|-------|--------|
| Source data | ton dictionnaire CSPro |
| Database name | nom de la DB cible (ex: `kairos_florida`) |
| Database type | `PostgreSQL` / `MySQL` / `SQL Server` |
| Hostname | `host.docker.internal` |
| Port | port exposé (ex: `5433`) |
| Database username | utilisateur de la DB cible |
| Database password | mot de passe de la DB cible |

---

## Étape 5 — Vérifier la connexion

Si la configuration est ajoutée avec succès, tu verras dans la liste :

```
host.docker.internal | kairos_florida
```

En cas d'erreur `Connection refused` → vérifier que :
1. Le container de la base cible est bien démarré (`docker ps`)
2. Le port dans le formulaire correspond au port **exposé** (côté hôte), pas le port interne
3. Sur Linux (pas macOS), `host.docker.internal` peut ne pas exister — utiliser la gateway du réseau Docker à la place :
   ```bash
   docker network inspect csweb8_pg_csweb-network --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}'
   # ex: 172.24.0.1
   ```

---

## Commandes utiles

```bash
# Voir tous les containers actifs et leurs ports
docker ps

# Voir le réseau d'un container
docker inspect <container_name> --format '{{json .NetworkSettings.Networks}}'

# Voir les containers d'un réseau
docker network inspect <network_name> --format '{{range .Containers}}{{.Name}} {{end}}'

# Obtenir la gateway d'un réseau Docker (Linux fallback)
docker network inspect <network_name> --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}'
```
