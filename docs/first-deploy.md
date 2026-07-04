# First Deploy

1. Configure SSH key access for the deploy user.
2. Confirm the deploy user can access the target application path.
3. Configure database credentials through CI/CD secrets or a server-side `.env`.
4. Run `deploysilas health`.
5. Run `deploysilas backup`.
6. Run `deploysilas deploy`.

DeploySilas runs outside the application and does not rewrite application includes, autoloaders, or path constants.
