#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/bootstrap.sh
source "$SCRIPT_DIR/lib/bootstrap.sh"

runtime_file() {
  printf '%s/runtime/last-deploy\n' "$(deploysilas_lock_dir)"
}

last_previous_commit() {
  local file
  file="$(runtime_file)"
  if [[ -f "$file" ]]; then
    awk -F= '$1 == "previous" {print $2}' "$file"
  fi
}

parse_target() {
  local target=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --commit)
        target="${2:-}"
        shift 2
        ;;
      --tag)
        target="${2:-}"
        shift 2
        ;;
      --last)
        target="$(last_previous_commit)"
        shift
        ;;
      --help|-h)
        printf 'Usage: rollback [--last] [--commit SHA] [--tag TAG] [REF]\n'
        exit 0
        ;;
      *)
        target="$1"
        shift
        ;;
    esac
  done

  if [[ -z "$target" ]]; then
    target="$(last_previous_commit)"
  fi

  [[ -n "$target" ]] || {
    printf 'No rollback target found. Provide --commit, --tag, ref, or run after a deploy.\n' >&2
    return 1
  }

  printf '%s\n' "$target"
}

main() {
  deploysilas_require git
  deploysilas_acquire_lock rollback
  trap deploysilas_release_lock EXIT

  local target current
  target="$(parse_target "$@")"

  deploysilas_info rollback "Starting rollback to $target"
  git -C "$DEPLOYSILAS_APP_PATH" fetch "$DEPLOYSILAS_REPO_REMOTE" --tags
  git -C "$DEPLOYSILAS_APP_PATH" reset --hard "$target"
  git -C "$DEPLOYSILAS_APP_PATH" clean -fd

  if [[ -f "$DEPLOYSILAS_APP_PATH/composer.json" ]]; then
    deploysilas_require composer
    composer --working-dir="$DEPLOYSILAS_APP_PATH" install --no-dev --optimize-autoloader --no-interaction
  fi

  deploysilas_fix_permissions
  current="$(git -C "$DEPLOYSILAS_APP_PATH" rev-parse HEAD)"
  "$SCRIPT_DIR/version.sh" "$DEPLOYSILAS_APP_PATH/version.json"
  "$SCRIPT_DIR/health.sh"
  deploysilas_info rollback "Rollback completed: $current"
}

main "$@"
