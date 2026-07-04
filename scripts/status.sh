#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/bootstrap.sh
source "$SCRIPT_DIR/lib/bootstrap.sh"

main() {
  deploysilas_info deploy "Environment: $DEPLOYSILAS_ENV"
  deploysilas_info deploy "Application path: $DEPLOYSILAS_APP_PATH"
  deploysilas_info deploy "Branch: $DEPLOYSILAS_BRANCH"
  deploysilas_info deploy "Web server: $(deploysilas_detect_webserver)"

  if [[ -d "$DEPLOYSILAS_APP_PATH/.git" ]]; then
    deploysilas_info deploy "Commit: $(git -C "$DEPLOYSILAS_APP_PATH" rev-parse HEAD)"
    deploysilas_info deploy "Git status: $(git -C "$DEPLOYSILAS_APP_PATH" status --short | wc -l) changed file(s)"
  fi

  if [[ -f "$(deploysilas_lock_dir)/runtime/last-deploy" ]]; then
    cat "$(deploysilas_lock_dir)/runtime/last-deploy"
  fi
}

main "$@"
