#!/bin/bash
set -e

# Substitui o domínio no ficheiro de configuração
sed -i "s/DOMAIN_NAME_PLACEHOLDER/${DOMAIN_NAME}/g" /etc/nginx/sites-available/default

# Gera o certificado SSL self-signed se ainda não existir
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    echo "A gerar certificado SSL..."
    openssl req -x509 -nodes \
        -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=PT/ST=Lisboa/L=Lisboa/O=42/OU=42/CN=${DOMAIN_NAME}"
fi

echo "A arrancar NGINX..."
exec nginx -g "daemon off;"