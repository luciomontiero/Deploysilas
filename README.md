# DeploySilas

DeploySilas is a reusable DevOps framework for pure PHP applications, including legacy projects that cannot have their internal paths, includes, autoloaders, or directory structure changed.

It provides CI/CD, SSH deploy, backup, rollback, version metadata, database migrations, health checks, logs, and a small PHP dashboard without requiring Laravel or any other application framework.

## Principles

- Keep all deploy logic outside the application.
- Do not rewrite `include`, `require`, `require_once`, `__DIR__`, `dirname()`, autoloaders, or existing paths.
- Work with PHP 7.4+ and PHP 8.x.
- Support GitLab CI/CD and GitHub Actions.
- Use SSH keys and CI secrets, never passwords or credentials committed to Git.
- Prefer small, auditable shell scripts and plain PHP.

## Repository Layout

```text
.deploy/       DeploySilas runtime metadata and locks
.github/       GitHub Actions workflows
.gitlab/       GitLab support files
config/        Environment examples and deploy defaults
database/      SQL migrations
docs/          Project documentation
logs/          Local log directory placeholder
scripts/       Reusable CLI and automation scripts
templates/     Apache, Nginx, cron, supervisor, and systemd templates
tests/         Lightweight validation tests
```

## Target Server

Default examples target:

```text
/home/ocgtechcom/silas.ocgtech.com.br
```

Override all environment-specific values through `.env` files or CI/CD secrets.

## Quick Start

1. Copy one of the example files from `config/` to `.env` outside the application repository or configure equivalent CI/CD secrets.
2. Install the CLI wrapper:

   ```bash
   sudo ln -s "$(pwd)/scripts/deploysilas" /usr/local/bin/deploysilas
   ```

3. Validate locally:

   ```bash
   deploysilas health
   deploysilas status
   ```

4. Trigger deploy through GitLab CI/CD, GitHub Actions, or manually:

   ```bash
   deploysilas deploy
   ```

## Commands

- `deploy`
- `backup`
- `rollback`
- `status`
- `health`
- `logs`
- `version`
- `cleanup`
- `migrate`
- `update`
- `help`

See [docs/installation.md](docs/installation.md) and [docs/troubleshooting.md](docs/troubleshooting.md).
