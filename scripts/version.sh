#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/bootstrap.sh
source "$SCRIPT_DIR/lib/bootstrap.sh"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

main() {
  deploysilas_require git hostname date

  local root version commit branch user server current_date current_time target
  root="$(deploysilas_root)"
  version="$(tr -d '[:space:]' < "$root/VERSION")"
  commit="$(git -C "$DEPLOYSILAS_APP_PATH" rev-parse HEAD 2>/dev/null || git -C "$root" rev-parse HEAD)"
  branch="$(git -C "$DEPLOYSILAS_APP_PATH" rev-parse --abbrev-ref HEAD 2>/dev/null || git -C "$root" rev-parse --abbrev-ref HEAD)"
  user="${USER:-$(id -un)}"
  server="$(hostname -f 2>/dev/null || hostname)"
  current_date="$(date '+%Y-%m-%d')"
  current_time="$(date '+%H:%M:%S %z')"
  target="${1:-$root/version.json}"

  cat > "$target" <<JSON
{
  "name": "DeploySilas",
  "version": "$(json_escape "$version")",
  "commit": "$(json_escape "$commit")",
  "branch": "$(json_escape "$branch")",
  "user": "$(json_escape "$user")",
  "server": "$(json_escape "$server")",
  "date": "$(json_escape "$current_date")",
  "time": "$(json_escape "$current_time")"
}
JSON

  deploysilas_info deploy "Version metadata written to $target"
}

main "$@"
