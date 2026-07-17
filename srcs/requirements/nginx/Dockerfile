FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/sites-available/default
COPY tools/init.sh /init.sh

RUN chmod +x /init.sh
RUN mkdir -p /etc/nginx/ssl

EXPOSE 443

ENTRYPOINT ["/init.sh"]