# Quality

DeploySilas favors small Bash scripts, plain PHP, and explicit configuration.

Validation includes:

- PHP lint.
- Composer validation when `composer.json` exists.
- ShellCheck.
- YAML validation.
- Executable permission checks.

Run locally:

```bash
tests/permissions.sh
shellcheck scripts/*.sh scripts/deploysilas scripts/lib/*.sh
```
