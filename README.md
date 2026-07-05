# BookTracker (Reader)

A Rails 7 web + API application for cataloging a personal book library. Books are organized into shelves, enriched with metadata from ISBNdb and Claude (fiction/nonfiction classification + genres), and served to both a web UI and a JSON API consumed by a companion iOS app.

## Quick start

```bash
bundle install
bin/rails db:setup
bin/rails server          # http://localhost:3000
bin/rails test
```

## Documentation

- **[CLAUDE.md](CLAUDE.md)** — architecture, data model, testing conventions, and engineering methodology (start here)
- **[doc/ROADMAP.md](doc/ROADMAP.md)** — improvement priorities and the analysis behind them
- **[doc/DEPLOY.md](doc/DEPLOY.md)** — production setup (Hatchbox) and operations
- **[doc/api.md](doc/api.md)** — JSON API reference

Work is tracked in the WCP **BOOK** namespace; commits reference callsigns (e.g. `BOOK-11`).
