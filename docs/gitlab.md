# GitLab CI/CD

Configure protected variables:

- `DEPLOYSILAS_SSH_HOST`
- `DEPLOYSILAS_SSH_USER`
- `DEPLOYSILAS_SSH_PORT`
- `DEPLOYSILAS_SSH_PRIVATE_KEY`
- Database variables when remote backup is required

The pipeline validates code before deploy and cancels deployment on validation failure.
