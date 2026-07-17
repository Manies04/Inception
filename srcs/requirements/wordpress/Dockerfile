FROM debian:bookworm

# Install PHP-FPM and required extensions
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-zip \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/init.sh /init.sh

RUN chmod +x /init.sh

EXPOSE 9000

ENTRYPOINT ["/init.sh"]