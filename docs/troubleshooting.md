# Troubleshooting

## Deploy fails before SSH

Check CI variables and SSH key formatting.

## Health check fails after deploy

Review `logs/health.log`, web server status, PHP errors, database connectivity, and disk space.

## Rollback fails

Confirm the target commit or tag exists on the configured remote and that the deploy user can run Git in the application path.
