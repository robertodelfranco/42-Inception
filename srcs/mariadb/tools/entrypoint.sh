#!/bin/sh
set -e

DB_DIR="/var/lib/mysql"

mkdir -p "${DB_DIR}"
chown -R mysql:mysql "${DB_DIR}" || true
chmod 700 "${DB_DIR}" || true

# Se diretório do banco estiver vazio, inicializa
if [ ! -d ${DB_DIR}/mysql ]; then

  # inicializa o banco de dados
  if command -v mariadb-install-db >/dev/null 2>&1; then
    mariadb-install-db --user=mysql --datadir="${DB_DIR}"
  elif command -v mysql_install_db >/dev/null 2>&1; then
    mysql_install_db --user=mysql --datadir="${DB_DIR}"
  else
    echo "[mariadb-entrypoint] Nenhuma ferramenta de instalação encontrada (mariadb-install-db/mysql_install_db)" >&2
    exit 1
  fi

  # start temporário em background para executar scripts de inicialização
  mysqld --user=mysql --datadir=${DB_DIR} --skip-networking &
  pid="$!"

  # espera socket ficar disponível
  tries=0
  until mysqladmin ping --silent || [ $tries -ge 30 ]; do
    sleeps=1
    sleep $sleeps
    tries=$((tries+1))
  done

  echo "[mariadb-entrypoint] criando/ajustando database e usuário..."

  mysql -uroot <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
    ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL
  echo "[mariadb-entrypoint] database/usuário prontos."

  # mata o processo temporário antes de reiniciar em foreground
  kill $pid || true
  wait $pid 2>/dev/null || true
fi

# FINAL: exec do daemon em foreground (PID 1)
exec mysqld --user=mysql --datadir=${DB_DIR}