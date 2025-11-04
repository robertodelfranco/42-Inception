#!/bin/sh
set -e

sleep 2

# Se WP não existir no volume, baixa e configura
WP_CLI=/usr/local/bin/wp
WP_DIR=/var/www/html

mkdir -p "${WP_DIR}"
chown -R www-data:www-data "${WP_DIR}"

if [ ! -f "${WP_DIR}/wp-config.php" ]; then
  # baixa wp-cli
  curl -o ${WP_CLI} https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x ${WP_CLI}

  # download do wordpress
  if [ ! -f "${WP_DIR}/wp-load.php" ]; then
    echo "[wp-entrypoint] baixando WordPress..."
    ${WP_CLI} core download --allow-root
  fi

  # cria config
  ${WP_CLI} config create --dbname="${DB_NAME}" --dbuser="${DB_USER}" --dbpass="${DB_PASSWORD}" --dbhost="${DB_HOST}" --allow-root

  # instala admin username
  ${WP_CLI} core install --url="${DOMAIN}" --title="Inception" \
    --admin_user="${WP_ADMIN_USER}" --admin_password="${DB_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" --skip-email --allow-root

  # criar um usuário adicional
  ${WP_CLI} user create user01 user01@${DOMAIN} --user_pass="userpass123" --role=editor --allow-root
fi

# final: exec php-fpm em foreground (PID 1)
exec php-fpm8.2 -F