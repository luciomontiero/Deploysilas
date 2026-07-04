#!/usr/bin/env bash

set -Eeuo pipefail

deploysilas_has_ssh() {
  [[ -n "${DEPLOYSILAS_SSH_HOST:-}" && -n "${DEPLOYSILAS_SSH_USER:-}" ]]
}

deploysilas_ssh_args() {
  local args=(-p "$DEPLOYSILAS_SSH_PORT" -o BatchMode=yes -o StrictHostKeyChecking=accept-new)
  if [[ -n "${DEPLOYSILAS_SSH_KEY:-}" ]]; then
    args+=(-i "$DEPLOYSILAS_SSH_KEY")
  fi
  printf '%q ' "${args[@]}"
}

deploysilas_remote_target() {
  printf '%s@%s\n' "$DEPLOYSILAS_SSH_USER" "$DEPLOYSILAS_SSH_HOST"
}

deploysilas_ssh() {
  local target
  target="$(deploysilas_remote_target)"
  ssh -p "$DEPLOYSILAS_SSH_PORT" -o BatchMode=yes -o StrictHostKeyChecking=accept-new ${DEPLOYSILAS_SSH_KEY:+-i "$DEPLOYSILAS_SSH_KEY"} "$target" "$@"
}

deploysilas_run_app() {
  local command="$1"
  if deploysilas_has_ssh; then
    deploysilas_ssh "cd '$DEPLOYSILAS_APP_PATH' && $command"
  else
    (cd "$DEPLOYSILAS_APP_PATH" && bash -c "$command")
  fi
}
