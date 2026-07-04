#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/bootstrap.sh
source "$SCRIPT_DIR/lib/bootstrap.sh"

main() {
  deploysilas_require tar gzip find date
  deploysilas_acquire_lock backup
  trap deploysilas_release_lock EXIT

  local timestamp backup_dir file_archive db_archive
  timestamp="$(deploysilas_timestamp)"
  backup_dir="$DEPLOYSILAS_BACKUP_DIR/$timestamp"
  mkdir -p "$backup_dir"

  deploysilas_info backup "Starting backup for $DEPLOYSILAS_APP_PATH"

  file_archive="$backup_dir/files-$timestamp.tar.gz"
  tar --exclude='.git' --exclude='vendor' --exclude='node_modules' -czf "$file_archive" -C "$DEPLOYSILAS_APP_PATH" .
  deploysilas_info backup "Files backup created: $file_archive"

  if deploysilas_db_configured; then
    deploysilas_require mysqldump
    db_archive="$backup_dir/database-$timestamp.sql.gz"
    deploysilas_mysqldump "$DEPLOYSILAS_DB_NAME" | gzip > "$db_archive"
    deploysilas_info backup "Database backup created: $db_archive"
  else
    deploysilas_warn backup "Database variables not configured; skipping MySQL backup"
  fi

  find "$DEPLOYSILAS_BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -mtime "+$DEPLOYSILAS_RETENTION_DAYS" -print -exec rm -rf {} +
  deploysilas_info backup "Backup completed"
}

main "$@"
