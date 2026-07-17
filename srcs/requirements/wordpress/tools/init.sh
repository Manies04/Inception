#!/bin/bash
set -e

# Lê as secrets
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# Cria a pasta do WordPress se não existir
mkdir -p /var/www/wordpress
cd /var/www/wordpress

# Instala o WordPress só se ainda não estiver instalado
if [ ! -f wp-config.php ]; then
    echo "A descarregar WordPress..."
    wp core download --allow-root

    echo "A criar wp-config.php..."
    wp config create \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb:3306 \
        --allow-root

    echo "A instalar WordPress..."
    wp core install \
        --url=https://${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root

    echo "A criar utilizador extra..."
    wp user create \
        ${WP_USER} \
        ${WP_USER_EMAIL} \
        --role=author \
        --user_pass=${WP_USER_PASSWORD} \
        --allow-root

    echo "WordPress instalado!"
else
    echo "WordPress já instalado, a saltar configuração."
fi

# Arranca PHP-FPM em foreground
echo "A arrancar PHP-FPM..."
mkdir -p /run/php
exec php-fpm8.2 -F