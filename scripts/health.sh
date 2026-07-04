#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/bootstrap.sh
source "$SCRIPT_DIR/lib/bootstrap.sh"

failures=0

check_ok() {
  deploysilas_info health "OK: $*"
}

check_fail() {
  failures=$((failures + 1))
  deploysilas_error health "FAIL: $*"
}

check_command() {
  local label="$1" command_name="$2"
  if command -v "$command_name" >/dev/null 2>&1; then
    check_ok "$label found"
  else
    check_fail "$label missing"
  fi
}

check_webserver() {
  local webserver
  webserver="$(deploysilas_detect_webserver)"
  if [[ "$webserver" == "unknown" ]]; then
    check_fail "Apache or Nginx not detected"
  else
    check_ok "Web server detected: $webserver"
  fi
}

check_php() {
  if command -v php >/dev/null 2>&1; then
    php -v | head -n 1 | while read -r line; do check_ok "$line"; done
  else
    check_fail "PHP CLI missing"
  fi
}

check_database() {
  if deploysilas_db_configured; then
    if deploysilas_mysql --execute='SELECT 1' "$DEPLOYSILAS_DB_NAME" >/dev/null 2>&1; then
      check_ok "Database connection"
    else
      check_fail "Database connection"
    fi
  else
    deploysilas_warn health "Database variables not configured; skipping database check"
  fi
}

check_paths() {
  local dir
  [[ -d "$DEPLOYSILAS_APP_PATH" ]] || check_fail "Application path missing: $DEPLOYSILAS_APP_PATH"
  for dir in uploads storage; do
    if [[ -d "$DEPLOYSILAS_APP_PATH/$dir" ]]; then
      [[ -w "$DEPLOYSILAS_APP_PATH/$dir" ]] && check_ok "$dir writable" || check_fail "$dir not writable"
    else
      deploysilas_warn health "$dir directory not found; skipped"
    fi
  done
}

check_resources() {
  local disk memory
  disk="$(deploysilas_available_disk_mb)"
  memory="$(deploysilas_available_memory_mb)"

  (( disk >= DEPLOYSILAS_MIN_DISK_AVAILABLE_MB )) && check_ok "Disk available ${disk}MB" || check_fail "Low disk ${disk}MB"
  (( memory >= DEPLOYSILAS_MIN_MEMORY_AVAILABLE_MB )) && check_ok "Memory available ${memory}MB" || check_fail "Low memory ${memory}MB"

  if command -v uptime >/dev/null 2>&1; then
    check_ok "CPU/load: $(uptime | sed 's/^ *//')"
  fi
}

check_http() {
  if [[ -n "${DEPLOYSILAS_HEALTH_URL:-}" ]]; then
    if curl --fail --silent --show-error --max-time "$DEPLOYSILAS_HTTP_TIMEOUT" "$DEPLOYSILAS_HEALTH_URL" >/dev/null; then
      check_ok "HTTP response: $DEPLOYSILAS_HEALTH_URL"
    else
      check_fail "HTTP response: $DEPLOYSILAS_HEALTH_URL"
    fi
  else
    deploysilas_warn health "DEPLOYSILAS_HEALTH_URL not configured; skipping HTTP check"
  fi
}

main() {
  deploysilas_require awk curl df free sed
  deploysilas_info health "Starting health check"

  check_command Git git
  check_webserver
  check_php
  check_database
  check_paths
  check_resources
  check_http

  if (( failures > 0 )); then
    deploysilas_error health "Health check failed with $failures failure(s)"
    return 1
  fi

  deploysilas_info health "Health check passed"
}

main "$@"
