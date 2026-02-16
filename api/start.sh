#!/bin/bash
set -e

echo "=== Starting Jyotish API ==="

# Ensure PHP-FPM socket directory exists
mkdir -p /run/php
echo "Created /run/php directory"

# Start PHP-FPM in background (not via service, direct binary)
php-fpm7.4 --daemonize
echo "PHP-FPM started"

# Wait for the socket to be ready
for i in $(seq 1 10); do
    if [ -S /run/php/php7.4-fpm.sock ]; then
        echo "PHP-FPM socket ready"
        break
    fi
    echo "Waiting for PHP-FPM socket... ($i/10)"
    sleep 1
done

if [ ! -S /run/php/php7.4-fpm.sock ]; then
    echo "ERROR: PHP-FPM socket not found at /run/php/php7.4-fpm.sock"
    echo "Checking alternative locations..."
    find /run -name "*.sock" 2>/dev/null || true
    find /var/run -name "*.sock" 2>/dev/null || true
    echo "PHP-FPM config:"
    grep -r "listen " /etc/php/7.4/fpm/ 2>/dev/null || true
    exit 1
fi

echo "Starting nginx on port 9393..."
# Start nginx in foreground (keeps container alive)
nginx -g 'daemon off;'
