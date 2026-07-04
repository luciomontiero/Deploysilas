# Troubleshooting

## Deploy fails before SSH

Check CI variables and SSH key formatting.

## Health check fails after deploy

Review `logs/health.log`, web server status, PHP errors, database connectivity, and disk space.

## Rollback fails

Confirm the target commit or tag exists on the configured remote and that the deploy user can run Git in the application path.

## Permission errors

Confirm `DEPLOYSILAS_WEB_USER`, `DEPLOYSILAS_WEB_GROUP`, and `DEPLOYSILAS_WRITABLE_DIRS` match the VPS. On Debian and Ubuntu Apache commonly uses `www-data`.

## Composer fails

DeploySilas only runs Composer when `composer.json` exists. Check PHP version, Composer availability, and private package credentials in the deploy user's environment.
