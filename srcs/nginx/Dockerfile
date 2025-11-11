FROM debian:12-slim

RUN apt-get update && apt-get install -y nginx openssl \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -days 365 \
    -subj "/C=BR/ST=SP/L=SaoPaulo/O=42School/CN=rdel-fra.42.fr"

EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
