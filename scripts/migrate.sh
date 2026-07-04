#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/bootstrap.sh
source "$SCRIPT_DIR/lib/bootstrap.sh"

MIGRATIONS_DIR="${DEPLOYSILAS_MIGRATIONS_DIR:-$(deploysilas_root)/database/migrations}"
MIGRATIONS_TABLE="${DEPLOYSILAS_MIGRATIONS_TABLE:-deploysilas_migrations}"

ensure_database() {
  deploysilas_db_configured || {
    deploysilas_error migration "Database variables are required for migrations"
    return 1
  }
  deploysilas_require mysql
  deploysilas_mysql "$DEPLOYSILAS_DB_NAME" --execute="
CREATE TABLE IF NOT EXISTS $MIGRATIONS_TABLE (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  migration VARCHAR(255) NOT NULL UNIQUE,
  batch INT UNSIGNED NOT NULL,
  executed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)"
}

current_batch() {
  deploysilas_mysql "$DEPLOYSILAS_DB_NAME" --batch --skip-column-names --execute="SELECT COALESCE(MAX(batch), 0) FROM $MIGRATIONS_TABLE"
}

migration_executed() {
  local migration="$1"
  local result
  result="$(deploysilas_mysql "$DEPLOYSILAS_DB_NAME" --batch --skip-column-names --execute="SELECT COUNT(*) FROM $MIGRATIONS_TABLE WHERE migration = '$migration'")"
  [[ "$result" == "1" ]]
}

run_up() {
  local batch migration name
  batch=$(( $(current_batch) + 1 ))

  shopt -s nullglob
  for migration in "$MIGRATIONS_DIR"/*; do
    [[ -d "$migration" && -f "$migration/up.sql" ]] || continue
    name="$(basename "$migration")"
    if migration_executed "$name"; then
      deploysilas_info migration "Skipping already executed migration: $name"
      continue
    fi
    deploysilas_info migration "Running migration: $name"
    deploysilas_mysql "$DEPLOYSILAS_DB_NAME" < "$migration/up.sql"
    deploysilas_mysql "$DEPLOYSILAS_DB_NAME" --execute="INSERT INTO $MIGRATIONS_TABLE (migration, batch) VALUES ('$name', $batch)"
  done
}

run_down() {
  local target name migration
  target="$(deploysilas_mysql "$DEPLOYSILAS_DB_NAME" --batch --skip-column-names --execute="SELECT migration FROM $MIGRATIONS_TABLE ORDER BY id DESC LIMIT 1")"
  [[ -n "$target" ]] || {
    deploysilas_info migration "No migration to roll back"
    return 0
  }

  migration="$MIGRATIONS_DIR/$target"
  [[ -f "$migration/down.sql" ]] || {
    deploysilas_error migration "Missing down.sql for $target"
    return 1
  }

  name="$(basename "$migration")"
  deploysilas_info migration "Rolling back migration: $name"
  deploysilas_mysql "$DEPLOYSILAS_DB_NAME" < "$migration/down.sql"
  deploysilas_mysql "$DEPLOYSILAS_DB_NAME" --execute="DELETE FROM $MIGRATIONS_TABLE WHERE migration = '$name'"
}

main() {
  deploysilas_acquire_lock migration
  trap deploysilas_release_lock EXIT
  ensure_database

  case "${1:-up}" in
    up)
      run_up
      ;;
    down|rollback)
      run_down
      ;;
    status)
      deploysilas_mysql "$DEPLOYSILAS_DB_NAME" --execute="SELECT migration, batch, executed_at FROM $MIGRATIONS_TABLE ORDER BY id"
      ;;
    *)
      printf 'Usage: migrate [up|down|rollback|status]\n' >&2
      return 1
      ;;
  esac
}

main "$@"
