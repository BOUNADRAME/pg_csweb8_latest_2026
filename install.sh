#!/bin/bash

# ============================================================================
# CSWeb Community Platform - Installation Interactive Script
# ============================================================================
# Author: Bouna DRAME
# Date: 14 Mars 2026
# Version: 2.0.0
#
# Description:
#   Installation interactive avec choix du mode (local/remote) et type de DB
#   Support: PostgreSQL, MySQL, SQL Server (local ou remote)
#
# Usage:
#   chmod +x install.sh
#   ./install.sh
# ============================================================================

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Functions
print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                        ║"
    echo "║         🚀 CSWeb Community Platform v2.0.0                            ║"
    echo "║            Installation Interactive                                    ║"
    echo "║                                                                        ║"
    echo "╚════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_step() {
    echo -e "${MAGENTA}▸ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_step "Vérification des prérequis..."
    echo ""

    if ! command -v docker &> /dev/null; then
        print_error "Docker n'est pas installé"
        echo "  Visitez: https://docs.docker.com/get-docker/"
        exit 1
    fi
    print_success "Docker installé"

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose n'est pas installé"
        echo "  Visitez: https://docs.docker.com/compose/install/"
        exit 1
    fi
    print_success "Docker Compose installé"

    if ! docker info &> /dev/null; then
        print_error "Docker daemon n'est pas démarré"
        echo "  Démarrez Docker Desktop ou le service Docker"
        exit 1
    fi
    print_success "Docker daemon actif"

    echo ""
}

# Generate password
generate_password() {
    openssl rand -base64 24 | tr -d "=+/" | cut -c1-24
}

# Ask breakout mode
ask_breakout_mode() {
    print_header
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  ÉTAPE 1/3 : Mode de Déploiement Breakout${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Où voulez-vous héberger la base de données de breakout ?"
    echo ""
    echo -e "  ${GREEN}1)${NC} ${BLUE}Local${NC}  - Docker containers (développement, test)"
    echo "     └─ Facile à démarrer, tout en local"
    echo "     └─ Recommandé pour : Dev, tests, POC"
    echo ""
    echo -e "  ${GREEN}2)${NC} ${BLUE}Remote${NC} - Serveur distant (production)"
    echo "     └─ Connexion à un serveur existant"
    echo "     └─ Recommandé pour : Production, RGPH5, serveurs dédiés"
    echo ""
    echo -n "Choix [1-2] (défaut: 1): "
    read -r mode_choice

    case $mode_choice in
        2)
            BREAKOUT_MODE="remote"
            print_info "Mode sélectionné: ${YELLOW}REMOTE${NC} (serveur distant)"
            ;;
        *)
            BREAKOUT_MODE="local"
            print_info "Mode sélectionné: ${YELLOW}LOCAL${NC} (Docker containers)"
            ;;
    esac

    sleep 1
}

# Ask database type
ask_database_type() {
    print_header
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  ÉTAPE 2/3 : Type de Base de Données Breakout${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Quel type de base de données voulez-vous utiliser pour le breakout ?"
    echo ""
    echo -e "  ${GREEN}1)${NC} ${BLUE}PostgreSQL${NC} (recommandé)"
    echo "     └─ Excellent pour analytics, JSON natif, performant"
    echo "     └─ Recommandé pour : Nouveaux projets, analytics avancés"
    echo ""
    echo -e "  ${GREEN}2)${NC} ${BLUE}MySQL${NC}"
    echo "     └─ Compatible, performant, familier"
    echo "     └─ Recommandé pour : Compatibilité, infrastructure MySQL existante"
    echo ""
    echo -e "  ${GREEN}3)${NC} ${BLUE}SQL Server${NC}"
    echo "     └─ Enterprise, robuste (RGPH5 Sénégal)"
    echo "     └─ Recommandé pour : Production enterprise, RGPH, infrastructure Microsoft"
    echo ""
    echo -n "Choix [1-3] (défaut: 1): "
    read -r db_choice

    case $db_choice in
        2)
            BREAKOUT_DB_TYPE="mysql"
            print_info "Base de données: ${YELLOW}MySQL${NC}"
            ;;
        3)
            BREAKOUT_DB_TYPE="sqlserver"
            print_info "Base de données: ${YELLOW}SQL Server${NC}"
            ;;
        *)
            BREAKOUT_DB_TYPE="postgresql"
            print_info "Base de données: ${YELLOW}PostgreSQL${NC}"
            ;;
    esac

    sleep 1
}

# Ask remote connection details
ask_remote_details() {
    print_header
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  ÉTAPE 3/3 : Configuration Serveur Remote${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    print_warning "Mode REMOTE détecté - Configuration du serveur distant"
    echo ""

    case $BREAKOUT_DB_TYPE in
        postgresql)
            echo "Configuration PostgreSQL Remote:"
            echo -n "  Hostname/IP : "
            read -r POSTGRES_HOST
            echo -n "  Port (défaut: 5432) : "
            read -r POSTGRES_PORT
            POSTGRES_PORT=${POSTGRES_PORT:-5432}
            echo -n "  Database : "
            read -r POSTGRES_DATABASE
            echo -n "  Username : "
            read -r POSTGRES_USER
            echo -n "  Password : "
            read -rs POSTGRES_PASSWORD
            echo ""
            ;;
        mysql)
            echo "Configuration MySQL Remote:"
            echo -n "  Hostname/IP : "
            read -r MYSQL_BREAKOUT_HOST
            echo -n "  Port (défaut: 3306) : "
            read -r MYSQL_BREAKOUT_PORT
            MYSQL_BREAKOUT_PORT=${MYSQL_BREAKOUT_PORT:-3306}
            echo -n "  Database : "
            read -r MYSQL_BREAKOUT_DATABASE
            echo -n "  Username : "
            read -r MYSQL_BREAKOUT_USER
            echo -n "  Password : "
            read -rs MYSQL_BREAKOUT_PASSWORD
            echo ""
            ;;
        sqlserver)
            echo "Configuration SQL Server Remote:"
            echo -n "  Hostname/IP : "
            read -r SQLSERVER_HOST
            echo -n "  Port (défaut: 1433) : "
            read -r SQLSERVER_PORT
            SQLSERVER_PORT=${SQLSERVER_PORT:-1433}
            echo -n "  Database : "
            read -r SQLSERVER_DATABASE
            echo -n "  Username (sa) : "
            read -r SQLSERVER_USER
            SQLSERVER_USER=${SQLSERVER_USER:-sa}
            echo -n "  Password : "
            read -rs SQLSERVER_PASSWORD
            echo ""
            ;;
    esac

    print_success "Configuration remote enregistrée"
    sleep 1
}

# Create .env file
create_env_file() {
    print_step "Création du fichier .env..."
    echo ""

    if [ -f .env ]; then
        print_warning ".env existe déjà - Création d'un backup"
        cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
    fi

    # Generate passwords
    MYSQL_ROOT_PASS=$(generate_password)
    MYSQL_PASS=$(generate_password)
    APP_SECRET=$(openssl rand -hex 32)
    JWT_SECRET=$(openssl rand -base64 32)

    # Generate passwords for local mode
    if [ "$BREAKOUT_MODE" = "local" ]; then
        case $BREAKOUT_DB_TYPE in
            postgresql)
                POSTGRES_PASSWORD=$(generate_password)
                POSTGRES_HOST="postgres"
                POSTGRES_PORT="5432"
                POSTGRES_DATABASE="csweb_analytics"
                POSTGRES_USER="csweb_analytics"
                ;;
            mysql)
                MYSQL_BREAKOUT_PASSWORD=$(generate_password)
                MYSQL_BREAKOUT_HOST="mysql-breakout"
                MYSQL_BREAKOUT_PORT="3307"
                MYSQL_BREAKOUT_DATABASE="csweb_breakout"
                MYSQL_BREAKOUT_USER="breakout_user"
                ;;
            sqlserver)
                SQLSERVER_PASSWORD="CSWebStrong!Pass$(openssl rand -base64 8 | tr -d '=+/')"
                SQLSERVER_HOST="sqlserver"
                SQLSERVER_PORT="1433"
                SQLSERVER_DATABASE="CSWeb_Analytics"
                SQLSERVER_USER="sa"
                ;;
        esac
    fi

    # Create .env
    cat > .env << EOF
# ============================================================================
# CSWeb Community Platform - Configuration
# ============================================================================
# Généré le: $(date)
# Mode: ${BREAKOUT_MODE}
# Type DB: ${BREAKOUT_DB_TYPE}
# ============================================================================

# Breakout Configuration
BREAKOUT_MODE=${BREAKOUT_MODE}
BREAKOUT_DB_TYPE=${BREAKOUT_DB_TYPE}

# Application
APP_ENV=prod
APP_DEBUG=false
APP_SECRET=${APP_SECRET}
APP_TIMEZONE=UTC
CSWEB_PORT=8080

# MySQL Métadonnées CSWeb (LOCAL - FIXE)
MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_DATABASE=csweb_metadata
MYSQL_USER=csweb_user
MYSQL_PASSWORD=${MYSQL_PASS}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASS}

# PostgreSQL Breakout
POSTGRES_HOST=${POSTGRES_HOST:-postgres}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_DATABASE=${POSTGRES_DATABASE:-csweb_analytics}
POSTGRES_USER=${POSTGRES_USER:-csweb_analytics}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-}

# MySQL Breakout
MYSQL_BREAKOUT_HOST=${MYSQL_BREAKOUT_HOST:-mysql-breakout}
MYSQL_BREAKOUT_PORT=${MYSQL_BREAKOUT_PORT:-3307}
MYSQL_BREAKOUT_DATABASE=${MYSQL_BREAKOUT_DATABASE:-csweb_breakout}
MYSQL_BREAKOUT_USER=${MYSQL_BREAKOUT_USER:-breakout_user}
MYSQL_BREAKOUT_PASSWORD=${MYSQL_BREAKOUT_PASSWORD:-}

# SQL Server Breakout
SQLSERVER_HOST=${SQLSERVER_HOST:-sqlserver}
SQLSERVER_PORT=${SQLSERVER_PORT:-1433}
SQLSERVER_DATABASE=${SQLSERVER_DATABASE:-CSWeb_Analytics}
SQLSERVER_USER=${SQLSERVER_USER:-sa}
SQLSERVER_PASSWORD=${SQLSERVER_PASSWORD:-YourStrong!Passw0rd}

# Dev Tools
PHPMYADMIN_PORT=8081
PGADMIN_PORT=8082
PGADMIN_EMAIL=admin@csweb.local
PGADMIN_PASSWORD=admin123

# Security
JWT_SECRET=${JWT_SECRET}
JWT_EXPIRATION=86400000
FILES_FOLDER=/var/www/html/files
API_URL=http://localhost:8080/api/

# Logging
CSWEB_LOG_LEVEL=error
CSWEB_PROCESS_CASES_LOG_LEVEL=error
MAX_EXECUTION_TIME=300
EOF

    print_success ".env créé avec succès"
    echo ""
}

# Pull Docker images
pull_images() {
    print_step "Téléchargement des images Docker..."
    echo ""
    docker-compose pull --quiet
    print_success "Images téléchargées"
    echo ""
}

# Start services
start_services() {
    print_step "Démarrage des services Docker..."
    echo ""

    if [ "$BREAKOUT_MODE" = "local" ]; then
        case $BREAKOUT_DB_TYPE in
            postgresql)
                print_info "Démarrage: CSWeb + MySQL (metadata) + PostgreSQL (breakout)"
                docker-compose --profile local-postgres up -d
                ;;
            mysql)
                print_info "Démarrage: CSWeb + MySQL (metadata) + MySQL Breakout"
                docker-compose --profile local-mysql up -d
                ;;
            sqlserver)
                print_info "Démarrage: CSWeb + MySQL (metadata) + SQL Server (breakout)"
                docker-compose --profile local-sqlserver up -d
                ;;
        esac
    else
        print_info "Démarrage: CSWeb + MySQL (metadata) uniquement"
        print_info "Breakout: Connexion au serveur ${BREAKOUT_DB_TYPE} distant"
        docker-compose up -d csweb mysql
    fi

    echo ""
    print_success "Services démarrés"
    echo ""
}

# Wait for services
wait_for_services() {
    print_step "Attente de la disponibilité des services..."
    echo ""

    echo -n "  MySQL (metadata)"
    for i in {1..30}; do
        if docker-compose exec -T mysql mysqladmin ping -h localhost --silent &> /dev/null; then
            echo -e " ${GREEN}✓${NC}"
            break
        fi
        echo -n "."
        sleep 2
    done

    if [ "$BREAKOUT_MODE" = "local" ]; then
        case $BREAKOUT_DB_TYPE in
            postgresql)
                echo -n "  PostgreSQL (breakout)"
                for i in {1..30}; do
                    if docker-compose exec -T postgres pg_isready -U csweb_analytics &> /dev/null; then
                        echo -e " ${GREEN}✓${NC}"
                        break
                    fi
                    echo -n "."
                    sleep 2
                done
                ;;
            mysql)
                echo -n "  MySQL Breakout"
                for i in {1..30}; do
                    if docker-compose exec -T mysql-breakout mysqladmin ping -h localhost --silent &> /dev/null; then
                        echo -e " ${GREEN}✓${NC}"
                        break
                    fi
                    echo -n "."
                    sleep 2
                done
                ;;
            sqlserver)
                echo -n "  SQL Server (breakout)"
                sleep 10  # SQL Server takes longer
                echo -e " ${GREEN}✓${NC}"
                ;;
        esac
    fi

    echo ""
    print_success "Tous les services sont prêts"
    echo ""
}

# Display final info
display_info() {
    print_header
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                        ║"
    echo "║              ✅ Installation Terminée avec Succès !                   ║"
    echo "║                                                                        ║"
    echo "╚════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""

    echo -e "${CYAN}📍 Accès CSWeb:${NC}"
    echo "  🌐 URL: http://localhost:8080"
    echo "  ⚙️  Setup: http://localhost:8080/setup/"
    echo ""

    echo -e "${CYAN}🎯 Configuration:${NC}"
    echo "  Mode: ${YELLOW}${BREAKOUT_MODE}${NC}"
    echo "  Base breakout: ${YELLOW}${BREAKOUT_DB_TYPE}${NC}"
    echo ""

    if [ "$BREAKOUT_MODE" = "local" ]; then
        echo -e "${CYAN}🛠️  Outils de développement:${NC}"
        echo "  📊 phpMyAdmin: http://localhost:8081"
        if [ "$BREAKOUT_DB_TYPE" = "postgresql" ]; then
            echo "  🐘 pgAdmin: http://localhost:8082"
            echo "      Email: admin@csweb.local"
            echo "      Password: admin123"
        fi
        echo ""
    fi

    echo -e "${CYAN}📝 Prochaines étapes:${NC}"
    echo "  1. Ouvrir http://localhost:8080/setup/"
    echo "  2. Remplir le formulaire avec:"
    echo "     - Database: csweb_metadata"
    echo "     - Host: mysql"
    echo "     - User: csweb_user"
    echo "     - Password: (voir .env - MYSQL_PASSWORD)"
    echo "  3. Se connecter avec admin/admin123"
    echo "  4. Uploader un dictionnaire CSPro"
    echo "  5. Lancer le breakout:"
    echo "     docker-compose exec csweb php bin/console csweb:process-cases-by-dict dictionnaires=DICT_NAME"
    echo ""

    echo -e "${CYAN}🔐 Credentials sauvegardés dans .env${NC}"
    echo ""

    echo -e "${CYAN}📚 Documentation:${NC}"
    echo "  Guide complet: docs/"
    echo "  Quick Start: QUICK-START.md"
    echo ""

    echo -e "${CYAN}💡 Commandes utiles:${NC}"
    echo "  docker-compose logs -f csweb        # Voir les logs"
    echo "  docker-compose ps                   # Statut des services"
    echo "  docker-compose down                 # Arrêter"
    echo "  docker-compose restart              # Redémarrer"
    echo ""

    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Made with ❤️  by Bouna DRAME - CSWeb Community Platform v2.0.0      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Main
main() {
    print_header
    sleep 1

    check_prerequisites
    ask_breakout_mode
    ask_database_type

    if [ "$BREAKOUT_MODE" = "remote" ]; then
        ask_remote_details
    fi

    create_env_file
    pull_images
    start_services
    wait_for_services
    display_info
}

# Run
main
