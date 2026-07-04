#!/usr/bin/env bash

set -Eeuo pipefail

DEPLOYSILAS_LOCK_FD=200

deploysilas_lock_dir() {
  local root
  root="$(deploysilas_root)"
  printf '%s/.deploy\n' "$root"
}

deploysilas_acquire_lock() {
  local name="${1:-deploysilas}"
  local lock_file
  lock_file="$(deploysilas_lock_dir)/${name}.lock"
  mkdir -p "$(dirname "$lock_file")"
  eval "exec ${DEPLOYSILAS_LOCK_FD}>\"$lock_file\""
  if ! flock -n "$DEPLOYSILAS_LOCK_FD"; then
    printf 'Another DeploySilas process is already running: %s\n' "$lock_file" >&2
    return 1
  fi
  printf '%s\n' "$$" 1>&"$DEPLOYSILAS_LOCK_FD"
}

deploysilas_release_lock() {
  flock -u "$DEPLOYSILAS_LOCK_FD" || true
}
