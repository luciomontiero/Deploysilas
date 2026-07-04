# Backup

Backups include application files and MySQL dumps when database settings are present.

Backups are compressed with gzip and rotated according to `DEPLOYSILAS_RETENTION_DAYS`.

```bash
deploysilas backup
```

Use cron from `templates/cron` for scheduled backups and `deploysilas cleanup` for manual rotation.
