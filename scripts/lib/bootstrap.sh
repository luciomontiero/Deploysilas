#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/lib/env.sh
source "$SCRIPT_DIR/env.sh"
# shellcheck source=scripts/lib/log.sh
source "$SCRIPT_DIR/log.sh"
# shellcheck source=scripts/lib/lock.sh
source "$SCRIPT_DIR/lock.sh"
# shellcheck source=scripts/lib/remote.sh
source "$SCRIPT_DIR/remote.sh"
# shellcheck source=scripts/lib/system.sh
source "$SCRIPT_DIR/system.sh"
# shellcheck source=scripts/lib/mysql.sh
source "$SCRIPT_DIR/mysql.sh"

deploysilas_load_env
