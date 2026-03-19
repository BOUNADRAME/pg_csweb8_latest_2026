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

    # Remove UNIQUE constraint on schema_name (required for multi-dictionary breakout)
    echo "[CSWeb] Checking schema_name constraint..."
    php -r "
        require '/var/www/html/src/AppBundle/config.php';
        try {
            \$pdo = new PDO('mysql:host=' . DBHOST . ';dbname=' . DBNAME . ';port=' . DBPORT, DBUSER, DBPASS);
            \$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            \$result = \$pdo->query(\"SHOW INDEX FROM cspro_dictionaries_schema WHERE Key_name = 'schema_name'\");
            if (\$result->rowCount() > 0) {
                \$pdo->exec('ALTER TABLE cspro_dictionaries_schema DROP KEY schema_name');
                echo '[CSWeb] Dropped UNIQUE constraint on schema_name' . PHP_EOL;
            } else {
                echo '[CSWeb] schema_name constraint already removed' . PHP_EOL;
            }
        } catch (Exception \$e) {
            echo '[CSWeb] Could not check/drop schema_name constraint: ' . \$e->getMessage() . PHP_EOL;
        }
    " 2>/dev/null || true
else
    echo "[CSWeb] config.php not found, skipping cache clear (run /setup first)."
fi

# Start cron daemon for breakout scheduler
if [ -f /etc/cron.d/csweb-scheduler ]; then
    echo "[CSWeb] Starting cron daemon for breakout scheduler..."
    cron
    echo "[CSWeb] Cron daemon started."
fi

echo "[CSWeb] Initialization complete. Starting Apache..."

# Execute the original CMD (apache2-foreground)
exec "$@"
