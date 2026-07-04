# Installation

DeploySilas can run locally on the VPS or remotely through CI/CD over SSH.

## Requirements

- Bash 4+
- Git
- PHP 7.4+
- MySQL client tools
- `tar`, `gzip`, `curl`, `df`, `free`, and common GNU/Linux utilities
- Optional: Composer, ShellCheck, and a YAML validator for CI

## Install CLI

```bash
sudo ln -s "$(pwd)/scripts/deploysilas" /usr/local/bin/deploysilas
```

## Configure

Copy the environment example that matches your stage and fill values outside Git:

```bash
cp config/production.env.example .env
```

Never commit `.env`.
