# Migrations

Each migration is a directory containing:

```text
database/migrations/202607040001_example/
  up.sql
  down.sql
```

DeploySilas records executed migrations in the `deploysilas_migrations` table.

Run:

```bash
deploysilas migrate up
deploysilas migrate down
deploysilas migrate status
```
