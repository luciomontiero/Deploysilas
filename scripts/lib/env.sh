#!/usr/bin/env bash

set -Eeuo pipefail

deploysilas_root() {
  local source_dir
  source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  printf '%s\n' "$source_dir"
}

deploysilas_load_env() {
  local root env_file
  root="$(deploysilas_root)"
  env_file="${DEPLOYSILAS_ENV_FILE:-$root/.env}"

  if [[ -f "$env_file" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "$env_file"
    set +a
  fi

  : "${DEPLOYSILAS_ENV:=production}"
  : "${DEPLOYSILAS_APP_PATH:=/home/ocgtechcom/silas.ocgtech.com.br}"
  : "${DEPLOYSILAS_REPO_REMOTE:=origin}"
  : "${DEPLOYSILAS_BRANCH:=main}"
  : "${DEPLOYSILAS_BACKUP_DIR:=.deploy/backups}"
  : "${DEPLOYSILAS_RETENTION_DAYS:=14}"
  : "${DEPLOYSILAS_SSH_PORT:=22}"
  : "${DEPLOYSILAS_WEB_USER:=www-data}"
  : "${DEPLOYSILAS_WEB_GROUP:=www-data}"
  : "${DEPLOYSILAS_WRITABLE_DIRS:=uploads storage logs}"
  : "${DEPLOYSILAS_HTTP_TIMEOUT:=15}"
  : "${DEPLOYSILAS_MIN_DISK_AVAILABLE_MB:=512}"
  : "${DEPLOYSILAS_MIN_MEMORY_AVAILABLE_MB:=128}"

  export DEPLOYSILAS_ENV DEPLOYSILAS_APP_PATH DEPLOYSILAS_REPO_REMOTE
  export DEPLOYSILAS_BRANCH DEPLOYSILAS_BACKUP_DIR DEPLOYSILAS_RETENTION_DAYS
  export DEPLOYSILAS_SSH_PORT DEPLOYSILAS_WEB_USER DEPLOYSILAS_WEB_GROUP
  export DEPLOYSILAS_WRITABLE_DIRS DEPLOYSILAS_HTTP_TIMEOUT
  export DEPLOYSILAS_MIN_DISK_AVAILABLE_MB DEPLOYSILAS_MIN_MEMORY_AVAILABLE_MB
}

deploysilas_require() {
  local missing=0 command_name
  for command_name in "$@"; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
      printf 'Missing required command: %s\n' "$command_name" >&2
      missing=1
    fi
  done
  return "$missing"
}

deploysilas_timestamp() {
  date '+%Y%m%d-%H%M%S'
}

deploysilas_iso_datetime() {
  date '+%Y-%m-%dT%H:%M:%S%z'
}
