FROM debian:12-slim

RUN apt-get update && apt-get install -y \
    php8.2-fpm php8.2-mysql php8.2-xml php8.2-mbstring \
    curl wget ca-certificates unzip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

COPY listen.conf /etc/php/8.2/fpm/pool.d/www.conf

RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html
EXPOSE 9000
CMD ["/usr/local/bin/entrypoint.sh"]