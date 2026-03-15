#!/bin/bash

# Script de démarrage dev pour CSWeb Community Docs (Nextra)

echo "========================================="
echo "CSWeb Community Platform - Nextra Docs"
echo "========================================="
echo ""

# Vérifier que npm est installé
if ! command -v npm &> /dev/null; then
    echo "❌ npm n'est pas installé. Installez Node.js depuis https://nodejs.org"
    exit 1
fi

echo "✅ npm trouvé: $(npm --version)"

# Vérifier que node_modules existe
if [ ! -d "node_modules" ]; then
    echo "📦 Installation des dépendances NPM..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Erreur lors de l'installation des dépendances"
        exit 1
    fi
    echo "✅ Dépendances installées"
else
    echo "✅ Dépendances déjà installées"
fi

echo ""
echo "🚀 Démarrage du serveur de développement..."
echo ""
echo "📖 Documentation accessible sur: http://localhost:3000"
echo ""
echo "⌨️  Commandes utiles:"
echo "  - Ctrl+C : Arrêter le serveur"
echo "  - npm run build : Build production"
echo "  - npm run lint : Vérifier le code"
echo ""
echo "========================================="
echo ""

# Démarrer Next.js dev server
npm run dev
