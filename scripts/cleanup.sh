#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/bootstrap.sh
source "$SCRIPT_DIR/lib/bootstrap.sh"

main() {
  deploysilas_acquire_lock cleanup
  trap deploysilas_release_lock EXIT

  mkdir -p "$DEPLOYSILAS_BACKUP_DIR"
  find "$DEPLOYSILAS_BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -mtime "+$DEPLOYSILAS_RETENTION_DAYS" -print -exec rm -rf {} +
  deploysilas_info cleanup "Cleanup completed for backups older than $DEPLOYSILAS_RETENTION_DAYS days"
}

main "$@"
