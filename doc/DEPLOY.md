# Deployment

Production is a **Hatchbox-managed DigitalOcean droplet**. Everything below was verified against the live server (July 2026).

## Topology

| Thing | Value |
|---|---|
| Server | `cold-wind-4102` — `147.182.181.10` (shared with davepaola-com, pet-med-reminder, show-notes) |
| SSH | `ssh deploy@147.182.181.10` |
| App root | `/home/deploy/book-tracker/` (Capistrano-style: `current` → `releases/<timestamp>`, plus `repo` and `shared`) |
| Ruby | 3.1.2 via asdf (`~/.tool-versions` in the release dir) |
| App server | Puma, run as a **user systemd service**: `book-tracker-server.service`, bound to `127.0.0.1:$PORT` |
| Database | SQLite: `/home/deploy/book-tracker/shared/production.sqlite3` |
| Logs | `/home/deploy/book-tracker/shared/log/` |
| Env vars | Managed in the Hatchbox dashboard; injected via `EnvironmentFile=~/book-tracker/.asdf-vars` |

## Deploying

**Merging/pushing to `main` auto-deploys** via Hatchbox's GitHub integration. There is no manual deploy step. Migrations run as part of the deploy.

The `heroku` git remote and the Postgres dumps in `database-backups/` are relics of the pre-Nov-2023 Heroku deployment (retired when PR #20 moved the app to SQLite). Ignore them.

## Common operations

All of these need a login shell (`bash -lc`) so asdf + env vars load.

```bash
# One-off rake task / console
ssh deploy@147.182.181.10
cd ~/book-tracker/current
RAILS_ENV=production bundle exec rails console
RAILS_ENV=production bundle exec rails books:classify

# Restart the app
systemctl --user restart book-tracker-server

# Tail app logs
tail -f ~/book-tracker/shared/log/production.log
```

## Pulling a copy of the production DB

```bash
ssh deploy@147.182.181.10 'sqlite3 ~/book-tracker/shared/production.sqlite3 ".backup /tmp/book-tracker-prod.sqlite3"'
scp deploy@147.182.181.10:/tmp/book-tracker-prod.sqlite3 ./
```

## Gotchas

- **Long rake tasks buffer their output.** stdout redirected to a file is block-buffered (~8KB chunks), so a log can look stalled while the task is working. `lib/tasks/books.rake` sets `$stdout.sync = true`; do the same in new tasks, or check the DB for real progress.
- The `deploy` user's non-login shell has no Ruby on PATH — always `bash -lc` for scripted SSH commands.
- Rails warns about SQLite in production on every boot; known and accepted (single-user app).
