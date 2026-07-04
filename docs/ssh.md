# SSH

Use a dedicated deploy user and SSH keys.

Do not place passwords in scripts. Configure keys through CI/CD secrets or a protected server-side path.

Recommended permissions:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
```
