#!/bin/sh
set -e

sleep 2

WP_CLI=/usr/local/bin/wp
WP_DIR=/var/www/html

# make sure wp directory exists because of bind mount
mkdir -p "${WP_DIR}"
chown -R www-data:www-data "${WP_DIR}"

if [ ! -f "${WP_DIR}/wp-config.php" ]; then
  # baixa wp-cli
  if [ ! -x "${WP_CLI}" ]; then
    if ! curl -sSL -o "${WP_CLI}" https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar; then
      echo "[wp-entrypoint] erro ao baixar wp-cli" >&2
      exit 1
    fi
    chmod +x "${WP_CLI}"
  fi

  # download do wordpress
  if [ ! -f "${WP_DIR}/wp-load.php" ]; then
    echo "[wp-entrypoint] baixando WordPress..."
    ${WP_CLI} core download --path="${WP_DIR}" --allow-root
  fi

  # cria wp-config
  ${WP_CLI} config create --path="${WP_DIR}" --dbname="${DB_NAME}" --dbuser="${DB_USER}" --dbpass="${DB_PASSWORD}" --dbhost="${DB_HOST}" --allow-root

  # instala admin username
  ${WP_CLI} core install --path="${WP_DIR}" --url="${DOMAIN}" --title="Inception" \
    --admin_user="${WP_ADMIN_USER}" --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" --skip-email --allow-root

  # criar um usuário adicional
  if [ -n "${EXTRA_USER:-}" ] && [ -n "${EXTRA_USER_EMAIL:-}" ]; then
    if ! ${WP_CLI} user get "${EXTRA_USER}" --path="${WP_DIR}" --allow-root >/dev/null 2>&1; then
      ${WP_CLI} user create "${EXTRA_USER}" "${EXTRA_USER_EMAIL}" --user_pass="${EXTRA_USER_PASSWORD}" --role=editor --allow-root
    else
      echo "[wp-entrypoint] usuário ${EXTRA_USER} já existe, pulando criação"
    fi
  fi

# final: exec php-fpm em foreground (PID 1)
exec php-fpm8.2 -F