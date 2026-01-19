# Reader - Agent Instructions

This project uses **bd** (beads) for issue tracking and **gt** (Gas Town) for agent coordination.

---

## Project Overview

Reader is a book tracking Rails application. Users can catalog books, organize them into shelves, and enhance book data via ISBN lookup.

### Tech Stack

| Component | Technology |
|-----------|------------|
| Ruby | 3.1.2 |
| Rails | 7.0.4 |
| Database | SQLite3 |
| Auth | Devise (web) + API keys (API) |
| Frontend | Stimulus, Turbo, Importmap |
| Search | Ransack |
| Pagination | Pagy |

### Key Models

- **User** - Has many books and shelves, has api_key for API auth
- **Book** - Belongs to user and shelf, has ISBN lookup, attached cover image
- **Shelf** - User-created collections of books

### API Endpoints

```
POST /api/v1/sessions     # Login → returns user_id + api_key
GET  /api/v1/shelves      # List shelves with book counts
GET  /api/v1/books        # List all books
```

*Requires `?api_key=...&user_id=...` query params on GET requests.*

### Common Commands

```bash
bin/rails server          # Start server (localhost:3000)
bin/rails test            # Run tests
bin/rails db:migrate      # Run migrations
bin/rails console         # Rails console
```

### Directory Structure

```
app/
├── controllers/
│   ├── api/v1/           # API endpoints
│   ├── books_controller.rb
│   └── shelves_controller.rb
├── models/
│   ├── user.rb
│   ├── book.rb
│   └── shelf.rb
└── views/
```

### Documentation

- `doc/PRD.md` - Product requirements
- `doc/SDD.md` - Software design
- `doc/ios_api_auth.md` - iOS API authentication guide

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
gt hook               # Check your hooked work
gt done               # Signal completion to Gas Town
```

---

## Polecat Workflow (CRITICAL)

If you are a **polecat** (worker agent), follow this EXACT workflow:

### 1. On Startup - Sync and Check Hook

```bash
# FIRST: Pull latest from main (polecats may have merged while you were idle)
git pull origin main

# THEN: Check your assigned work
gt hook
```

This shows the bead assigned to you. Read it carefully - this is your task.

### 2. Do the Work

- Implement what the bead describes
- Make atomic commits as you go
- Run tests if applicable

### 3. On Completion - MANDATORY STEPS

You MUST complete ALL of these steps. Work is NOT done until all succeed:

```bash
# 1. Stage and commit your changes
git add -A
git commit -m "Description of what you did"

# 2. Close your bead (USE THE ACTUAL BEAD ID from gt hook)
bd close <bead-id> --reason="Implemented feature"

# 3. Sync beads
bd sync

# 4. Push to remote - MANDATORY
git push origin HEAD

# 5. Verify push succeeded
git status  # Must show "up to date with origin" or "ahead" is OK if remote updated

# 6. Signal done to Gas Town
gt done
```

### CRITICAL RULES

- **ALWAYS close your bead** - Use `bd close <id>` with the bead ID from `gt hook`
- **ALWAYS push** - Work is NOT complete until `git push` succeeds
- **ALWAYS run `gt done`** - This signals Gas Town you're finished
- **NEVER stop before pushing** - That leaves work stranded locally
- **NEVER say "ready to push when you are"** - YOU must push

### If Push Fails

```bash
git pull --rebase origin main
# Resolve any conflicts
git push origin HEAD
```

---

## Landing the Plane (Session Completion)

**When ending a work session**, complete ALL steps:

1. **Commit all changes** - `git add -A && git commit -m "..."`
2. **Close your bead** - `bd close <bead-id>`
3. **Sync beads** - `bd sync`
4. **Push to remote** - `git push origin HEAD`
5. **Signal done** - `gt done`
6. **Verify** - `git status` shows clean and pushed

---

## For Crew (Human-Managed Workers)

Crew members follow the same workflow but without `gt done` (you're managed by a human, not Gas Town).

### CRITICAL: Pull Before Starting Work

Crew worktrees persist across sessions. Polecats may have merged work to main while you were offline. **ALWAYS pull before starting any work:**

```bash
# EVERY session start - MANDATORY
git pull origin main
```

If you skip this, you'll be working on stale code and may miss features that polecats already implemented.

### On Completion

```bash
git add -A && git commit -m "..."
bd close <bead-id>
bd sync
git push origin main
```
