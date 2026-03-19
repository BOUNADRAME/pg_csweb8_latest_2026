#!/bin/bash
# ============================================================================
# CSWeb Community Platform - Docker Entrypoint
# ============================================================================
# Executed at container startup before Apache
# Handles: permissions, cache clearing, directory creation
# ============================================================================

set -e

echo "[CSWeb] Starting container initialization..."

# Ensure required directories exist with correct permissions
mkdir -p /var/www/html/var/cache
mkdir -p /var/www/html/var/logs
mkdir -p /var/www/html/files

# Fix permissions for writable directories
chown -R www-data:www-data /var/www/html/var
chown -R www-data:www-data /var/www/html/files
chmod -R 777 /var/www/html/var
chmod -R 775 /var/www/html/files

# Clear Symfony cache if config.php exists (app is configured)
if [ -f /var/www/html/src/AppBundle/config.php ]; then
    echo "[CSWeb] config.php found, clearing Symfony cache..."
    php bin/console cache:clear --no-warmup 2>/dev/null || true
    php bin/console cache:warmup 2>/dev/null || true
    chown -R www-data:www-data /var/www/html/var
    chmod -R 777 /var/www/html/var
    echo "[CSWeb] Cache cleared successfully."
else
    echo "[CSWeb] config.php not found, skipping cache clear (run /setup first)."
fi

echo "[CSWeb] Initialization complete. Starting Apache..."

# Execute the original CMD (apache2-foreground)
exec "$@"
