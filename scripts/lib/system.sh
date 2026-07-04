#!/usr/bin/env bash

set -Eeuo pipefail

deploysilas_detect_webserver() {
  if command -v systemctl >/dev/null 2>&1; then
    if systemctl list-unit-files apache2.service >/dev/null 2>&1 || systemctl is-active --quiet apache2; then
      printf 'apache\n'
      return 0
    fi
    if systemctl list-unit-files nginx.service >/dev/null 2>&1 || systemctl is-active --quiet nginx; then
      printf 'nginx\n'
      return 0
    fi
  fi

  if command -v apache2 >/dev/null 2>&1 || command -v httpd >/dev/null 2>&1; then
    printf 'apache\n'
    return 0
  fi
  if command -v nginx >/dev/null 2>&1; then
    printf 'nginx\n'
    return 0
  fi

  printf 'unknown\n'
}

deploysilas_fix_permissions() {
  local dir
  for dir in $DEPLOYSILAS_WRITABLE_DIRS; do
    if [[ -d "$DEPLOYSILAS_APP_PATH/$dir" ]]; then
      chmod -R ug+rwX "$DEPLOYSILAS_APP_PATH/$dir"
      chown -R "$DEPLOYSILAS_WEB_USER:$DEPLOYSILAS_WEB_GROUP" "$DEPLOYSILAS_APP_PATH/$dir" 2>/dev/null || true
    fi
  done
}

deploysilas_available_disk_mb() {
  df -Pm "$DEPLOYSILAS_APP_PATH" | awk 'NR == 2 {print $4}'
}

deploysilas_available_memory_mb() {
  free -m | awk '/Mem:/ {print $7}'
}
