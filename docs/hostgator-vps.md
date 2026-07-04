# HostGator VPS

For HostGator VPS on Ubuntu or Debian:

1. Create a dedicated deploy user.
2. Add the CI/CD public SSH key to `~/.ssh/authorized_keys`.
3. Grant only the permissions required for the application path and service reloads.
4. Confirm whether Apache or Nginx is installed.
5. Store database credentials outside Git.
