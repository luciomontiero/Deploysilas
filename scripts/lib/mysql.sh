#!/usr/bin/env bash

set -Eeuo pipefail

deploysilas_db_configured() {
  [[ -n "${DEPLOYSILAS_DB_NAME:-}" && -n "${DEPLOYSILAS_DB_USER:-}" ]]
}

deploysilas_mysql_defaults() {
  local args=(--host="${DEPLOYSILAS_DB_HOST:-localhost}" --port="${DEPLOYSILAS_DB_PORT:-3306}" --user="$DEPLOYSILAS_DB_USER")
  if [[ -n "${DEPLOYSILAS_DB_PASSWORD:-}" ]]; then
    args+=(--password="$DEPLOYSILAS_DB_PASSWORD")
  fi
  printf '%q ' "${args[@]}"
}

deploysilas_mysql() {
  mysql --host="${DEPLOYSILAS_DB_HOST:-localhost}" --port="${DEPLOYSILAS_DB_PORT:-3306}" --user="$DEPLOYSILAS_DB_USER" ${DEPLOYSILAS_DB_PASSWORD:+--password="$DEPLOYSILAS_DB_PASSWORD"} "$@"
}

deploysilas_mysqldump() {
  mysqldump --host="${DEPLOYSILAS_DB_HOST:-localhost}" --port="${DEPLOYSILAS_DB_PORT:-3306}" --user="$DEPLOYSILAS_DB_USER" ${DEPLOYSILAS_DB_PASSWORD:+--password="$DEPLOYSILAS_DB_PASSWORD"} "$@"
}
