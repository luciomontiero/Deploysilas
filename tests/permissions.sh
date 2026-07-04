#!/usr/bin/env bash

set -Eeuo pipefail

failed=0

require_executable() {
  local file="$1"
  if [[ ! -x "$file" ]]; then
    printf 'Expected executable file: %s\n' "$file" >&2
    failed=1
  fi
}

require_executable scripts/deploysilas

while IFS= read -r -d '' file; do
  require_executable "$file"
done < <(find scripts -type f -name '*.sh' -print0)

if (( failed > 0 )); then
  exit 1
fi

printf 'Permission validation passed\n'
