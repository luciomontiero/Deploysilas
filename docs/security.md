# Security

- Use a dedicated deploy user.
- Use SSH keys only.
- Store secrets in GitLab CI/CD variables, GitHub Actions secrets, or untracked server-side environment files.
- Do not commit database credentials, SSH keys, tokens, or passwords.
- Keep the dashboard behind VPN, HTTP auth, IP allowlists, or an internal vhost when possible.
- Set `DEPLOYSILAS_DASHBOARD_TOKEN` if dashboard actions are enabled.
- DeploySilas uses lock files to prevent simultaneous deploy, backup, rollback, migration, and cleanup operations.
