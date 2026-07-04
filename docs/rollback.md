# Rollback

DeploySilas supports rollback by:

- Last known deployed commit.
- Explicit commit SHA.
- Git tag.
- Manual target reference.

Examples:

```bash
deploysilas rollback
deploysilas rollback --commit abc1234
deploysilas rollback --tag v1.2.0
```
