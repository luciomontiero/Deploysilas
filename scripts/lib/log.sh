#!/usr/bin/env bash

set -Eeuo pipefail

deploysilas_log_dir() {
  local root
  root="$(deploysilas_root)"
  printf '%s/logs\n' "$root"
}

deploysilas_log_file() {
  local name="$1"
  printf '%s/%s.log\n' "$(deploysilas_log_dir)" "$name"
}

deploysilas_log() {
  local channel="$1"
  local level="$2"
  shift 2

  mkdir -p "$(deploysilas_log_dir)"
  printf '[%s] [%s] %s\n' "$(deploysilas_iso_datetime)" "$level" "$*" | tee -a "$(deploysilas_log_file "$channel")"
}

deploysilas_info() {
  deploysilas_log "$1" INFO "${*:2}"
}

deploysilas_warn() {
  deploysilas_log "$1" WARN "${*:2}"
}

deploysilas_error() {
  deploysilas_log "$1" ERROR "${*:2}" >&2
}
