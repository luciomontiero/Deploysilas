#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/bootstrap.sh
source "$SCRIPT_DIR/lib/bootstrap.sh"

write_last_deploy() {
  local previous="$1" current="$2"
  mkdir -p "$(deploysilas_lock_dir)/runtime"
  {
    printf 'previous=%s\n' "$previous"
    printf 'current=%s\n' "$current"
    printf 'branch=%s\n' "$DEPLOYSILAS_BRANCH"
    printf 'date=%s\n' "$(deploysilas_iso_datetime)"
  } > "$(deploysilas_lock_dir)/runtime/last-deploy"
}

run_git_deploy() {
  local previous current target_ref
  target_ref="${1:-$DEPLOYSILAS_BRANCH}"

  previous="$(git -C "$DEPLOYSILAS_APP_PATH" rev-parse HEAD)"
  deploysilas_info deploy "Previous commit: $previous"

  "$SCRIPT_DIR/backup.sh"

  git -C "$DEPLOYSILAS_APP_PATH" fetch "$DEPLOYSILAS_REPO_REMOTE"
  git -C "$DEPLOYSILAS_APP_PATH" reset --hard "$DEPLOYSILAS_REPO_REMOTE/$target_ref"
  git -C "$DEPLOYSILAS_APP_PATH" clean -fd

  if [[ -f "$DEPLOYSILAS_APP_PATH/composer.json" ]]; then
    deploysilas_require composer
    composer --working-dir="$DEPLOYSILAS_APP_PATH" install --no-dev --optimize-autoloader --no-interaction
  fi

  deploysilas_fix_permissions
  current="$(git -C "$DEPLOYSILAS_APP_PATH" rev-parse HEAD)"
  write_last_deploy "$previous" "$current"
  "$SCRIPT_DIR/version.sh" "$DEPLOYSILAS_APP_PATH/version.json"

  if ! "$SCRIPT_DIR/health.sh"; then
    deploysilas_error deploy "Health check failed; rolling back to $previous"
    "$SCRIPT_DIR/rollback.sh" --commit "$previous"
    return 1
  fi

  deploysilas_info deploy "Deploy completed: $current"
}

main() {
  deploysilas_require git
  deploysilas_acquire_lock deploy
  trap deploysilas_release_lock EXIT

  deploysilas_info deploy "Starting deploy to $DEPLOYSILAS_APP_PATH"
  run_git_deploy "${1:-$DEPLOYSILAS_BRANCH}"
}

main "$@"
