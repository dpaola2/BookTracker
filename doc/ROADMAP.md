# Roadmap: Highest-Leverage Improvements

Outcome of a full review (code, GitHub repo, WCP BOOK namespace) in July 2026. This doc records the analysis and priorities so future work doesn't re-derive them. Work items live in the WCP **BOOK** namespace.

## Where the app stood at review time

- `books` carried only `title`, `author`, `isbn`, `shelf_id`, `user_id` — no genre, classification, read status, or rating.
- **Status and sentiment were encoded in shelf names** ("👍 Books: Liked", "📚 To Read", "📖 In Progress", "👎 Abandoned / Disliked"). 10 of 12 shelves encoded status/sentiment; only 2 (🥙 Cookbooks, 💻 Programming Reference) were genre-ish. Nothing in the DB could answer "what scifi do we own?"
- `IsbnSearcher` discarded ISBNdb's `subjects`, `synopsis`, `pages`, and `date_published` — thousands of prior lookups stored no subject data.
- No DB indexes on `books.user_id`/`shelf_id`, no foreign keys, API auth via `api_key` + `user_id` as request params.
- Scoping data: 1,062 books in the Nov 2023 dump (`database-backups/dump.sql`), 1,272 in production at review time. ~78% had ISBNs. Single user.

## Priority 1 — Genre + fiction/nonfiction metadata enrichment ✅ SHIPPED

**BOOK-11**, PR #28 (merged July 2026). Motivating use case: new Kindle, wanted to find good unread scifi already in the catalog.

Key decisions, and why:

- **LLM-first backfill** (Claude Haiku, title+author → `{classification, genres[]}`) rather than metadata-lookup-first: 22% of books lack ISBNs, ISBNdb subject quality is inconsistent, and the existing 3,934 `isbn_search_results` rows contained no subject data anyway. ~1,272 books cost a few dollars.
- **Controlled genre vocabulary** (`Book::GENRES`, 27 values) enforced via JSON-schema-constrained API output — free-form genres would make filtering useless.
- **Structured facts as columns** (`classification`, `genres` on books), **raw source payloads retained** on `isbn_search_results` (subjects/synopsis/pages/date_published now persisted) so classification can be re-derived later.
- Prior art considered: ISBNdb `subjects` (inconsistent), BISAC codes via Google Books/Open Library (`FIC*` prefix = fiction; good fallback source), GoodReads CSV (exports no genres). LLM classification won on accuracy and coverage.

Backfill: `bin/rails books:classify` (idempotent — only touches `classification: nil`).

**Backfill ran July 2026.** Final production state: **1,243 books, 100% classified** — 326 fiction / 917 nonfiction. Top genres: History 280, Business 250, Biography & Memoir 197, Science/Self-Help 184 each, Science Fiction 180, Philosophy 171. The run also surfaced 29 orphaned rows (movies/TV/board games from the Sofa import pointing at deleted shelves — no FKs meant they survived shelf deletion); deleted after confirming the Sofa export is preserved in `public/SofaExport-17022023-212837.csv` (pre-delete DB backup at `~/book-tracker/shared/pre-orphan-delete-backup.sqlite3` on the server).

**Follow-ons shipped:** BOOK-12 (PR #30) made the root page a library dashboard; BOOK-13 (PR #31) reworked its IA — clickable stat tiles, top-genre badges deep-linking into search filters, a 📖 In Progress hero row with covers (shelf found by name match until read status is first-class — see Priority 2), recently *added* books (`created_at`; `updated_at` is clobbered by bulk ops like the backfill), and per-shelf cards showing the 3 newest additions with 6-month-idle shelves collapsed to count-only rows.

## Priority 2 — First-class `status` and `rating` on Book (proposed)

Free the shelves: add `status` (to_read / reading / read / abandoned) and a rating ("Loved, Meh, Disliked" — GitHub issue #6) as columns, so shelves can become collections/genres instead of encoding state in emoji names. Combined with Priority 1, "good unread scifi we own" becomes one query. The GoodReads importer already has this signal (`Exclusive Shelf`, `My Rating`) and currently lossy-compresses it into shelf names.

## Priority 3 — Foundation hardening (proposed)

- Indexes on `books.user_id`, `books.shelf_id`, `shelves.user_id` — every page scans without them.
- NOT NULL constraints + foreign keys (associations are Rails-only today — this is how the 29 orphaned Sofa-import rows survived their shelves being deleted).
- API auth: move from `api_key`+`user_id` request params (credentials end up in logs; `user_id` is redundant) to an `Authorization` header, look up by key alone. Requires a coordinated iOS app update.
- Dependabot: ~100 open vulnerability alerts on the repo (3 critical, 22 high as of July 2026).

## Also unblocked by Priority 1

- GitHub issue #10 (book synopses) — synopses now captured at ISBN-search time.
- GitHub issue #19 (GPT suggestions) — a recommender needs the metadata that now exists.

## Related docs

- [DEPLOY.md](DEPLOY.md) — production setup and operations
- [CLAUDE.md](../CLAUDE.md) — architecture and engineering methodology
- BOOK-11 in WCP — full brief, activity log, and scoping detail
