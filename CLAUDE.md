# BookTracker (Reader)

A Rails 7 web + API application for cataloging personal book libraries. Users organize books into shelves, enrich metadata via ISBNdb, and access their collection through both a web UI and a JSON API (consumed by a companion iOS app).

## Quick Start

```bash
bundle install
bin/rails db:setup        # creates + seeds SQLite DB
bin/rails server          # http://localhost:3000
bin/rails test            # run all tests (Minitest)
bin/rails test:system     # system tests (requires Chrome/Selenium)
```

## Stack

- **Framework:** Rails 7.0.4 / Ruby 3.1.2
- **Database:** SQLite3 (dev/test/prod)
- **Auth:** Devise (web sessions) + API key (mobile)
- **Frontend:** Hotwire (Turbo + Stimulus), SCSS, Importmaps
- **Storage:** Active Storage (local disk dev/test, S3 production)
- **Search:** Ransack (book filtering by title/author/ISBN)
- **Pagination:** Pagy
- **Rich text:** Action Text (book comments)
- **External API:** ISBNdb (book metadata + cover images)

## Architecture

### Data Model

```
User
├── has_many :shelves
├── has_many :books
├── shelf_id (default shelf reference)
└── api_key (auto-generated, unique)

Shelf
├── belongs_to :user
└── has_many :books, dependent: :destroy

Book
├── belongs_to :shelf
├── belongs_to :user
├── has_many :isbn_search_results, dependent: :destroy
├── has_one_attached :image (Active Storage)
└── has_rich_text :comments (Action Text)

IsbnSearchResult
└── belongs_to :book
    (stores: image_url, title, authors, isbn13, isbn10)
```

**Note:** No foreign keys at the DB level — associations enforced by Rails only. All data is user-scoped; controllers filter by `current_user`.

### Authentication

- **Web:** Devise session-based auth. All controllers use `before_action :authenticate_user!`.
- **API:** Requires `api_key` + `user_id` params on every request. API key is auto-generated on user creation. Login via `POST /api/v1/sessions` returns the key pair.

### Routes

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/` | Shelves index (root) |
| | `/books` | Book CRUD (web) |
| `POST` | `/books/:id/isbn_searches` | Trigger ISBN lookup |
| `POST` | `/books/:id/isbn_searches/:id/assignments` | Apply ISBN result to book |
| | `/shelves` | Shelf CRUD (web) |
| `POST` | `/shelves/:id/defaults` | Set default shelf |
| `GET` | `/book_searches` | Search/filter books |
| `POST` | `/api/v1/sessions` | API login |
| `GET` | `/api/v1/books` | List user's books (JSON) |
| `GET` | `/api/v1/books/:id` | Single book detail (JSON) |
| `GET` | `/api/v1/shelves` | List user's shelves (JSON) |
| `GET` | `/api/v1/shelves/:id` | Single shelf with books (JSON) |

### Service Objects (in `app/models/`)

- **IsbnSearcher** — Queries ISBNdb API by title+author or ISBN
- **IsbnAssigner** — Applies an ISBN search result to a book (updates metadata, downloads cover)
- **GoodReadsImporter** — Imports GoodReads CSV export (shelves, books, reviews)
- **SofaImporter** — Imports Sofa app CSV export

### Key Files

| Path | Purpose |
|------|---------|
| `app/models/` | Models + service objects |
| `app/controllers/api/v1/` | API controllers |
| `app/controllers/` | Web controllers |
| `config/routes.rb` | All route definitions |
| `db/schema.rb` | Current database schema |
| `test/` | Minitest test suite |
| `doc/` | API docs, PRD, SDD |

## Engineering Methodology

These conventions apply to every change in this codebase — features, bug fixes, refactors. Future agents and human engineers should follow them by default. Mirrored from the canonical template at `~/projects/assistant/03-living-docs/Engineering-Methodology.md` — update there first, then sync.

### 1. Always work from a plan, not vibes

Before writing code, produce (or read) two artifacts:

- **Requirements** — what behavior is expected, in plain language. Inputs, outputs, edge cases.
- **Technical gameplan** — how you'll achieve those requirements. Files to touch, data model changes, test strategy, rollback.

For trivial fixes the plan can be three bullets. For anything else, write it down. The plan is what we align on; the code is the consequence.

### 2. TDD by default — Red → Green → Refactor

Write a failing test first. Watch it fail. Write the minimum code to make it pass. Then refactor with the test as your safety net. Applies to:

- **New features** — the test specifies what "done" means before you start.
- **Bug fixes** — the test reproduces the bug and stays in the suite as a regression guard. **A bug fix without a regression test is not done.** Even a one-character fix gets a test that would have caught it.
- **Refactors** — existing tests must continue to pass; add new ones if you discover untested behavior in the area you're touching.

### 3. Test behavior, not implementation

Tests should describe **what** the system does, not **how** it does it.

- **Test the public interface.** Assert on return values and observable side effects of public methods. Don't test private methods directly — they're tested through the public interface.
- **Don't test what you don't own.** Don't assert that Rails, the database, or third-party gems work. Test that *your code* sends the right messages to them.
- **Incoming messages → assert result.** Public methods return values or cause side effects; assert those.
- **Outgoing command messages → assert sent.** When your object tells a collaborator to *do* something (create a record, send an email), assert the message was sent — not what happens inside the collaborator.
- **Outgoing query messages → don't test.** If your object asks a collaborator a question, don't assert that the question was asked. That's an implementation detail.
- **Mocks belong at boundaries** (HTTP, jobs, external APIs), not inside your own object graph.
- **Structural assertions are an anti-pattern.** Don't test file layout, line counts, or directory structure. If the public contract works, the structure is irrelevant.
- **A test that breaks when you refactor without changing behavior is testing the wrong thing.** Delete it or rewrite it.

### 4. Sandi Metz rules — guardrails, not laws

- **Classes ≤ 100 lines.** If a class exceeds 100 LOC, it's doing too much — extract a new object.
- **Methods ≤ 5 lines** (aspirational — use judgment). Long methods hide multiple responsibilities.
- **≤ 4 parameters per method.** More than 4 means you need a parameter object or the method is doing too much. Use keyword args.
- **Controllers instantiate one object.** The controller action creates/finds one primary object; logic lives in that object or its collaborators, not in the controller.

Break a rule when you have a good reason; document the reason. The point is to push you toward extraction when something is growing — not to mechanically count lines.

### 5. SOLID, briefly

- **Single Responsibility** — each class has one reason to change. Can't name it without "and"? Extract.
- **Open/Closed** — extend by adding new classes (services, executors, strategies), not by editing existing ones.
- **Liskov Substitution** — subclasses should be drop-in replaceable for their parents; the caller shouldn't need to know.
- **Interface Segregation** — clients depend only on what they use; don't fatten interfaces to satisfy unrelated callers.
- **Dependency Inversion** — depend on abstractions (duck-typed collaborators), not concretions. Inject collaborators so tests can substitute fakes without mocking frameworks.

### 6. In practice

- **Small objects > large objects.** When in doubt, extract a new class. A 30-line class with a clear name is better than a private method buried in a 300-line file.
- **Composition over inheritance.** Use modules for shared behavior; prefer injecting collaborators over deep inheritance hierarchies.
- **Tell, don't ask.** Send messages to objects rather than querying their state and making decisions for them.
- **Trust the message.** If you find yourself checking an object's type or state to decide what to do, push that decision into the object itself.
- **Objects play roles, not identities.** Design around *what messages an object responds to* (its role), not *what class it is* (its identity). Duck typing makes code open to extension: new objects can play existing roles without modifying callers.

---

## Testing in this repo

### Framework & Setup

- **Minitest** with Rails test helpers
- **SimpleCov** for code coverage (reports to `coverage/`)
- **Fixtures** for test data (`test/fixtures/*.yml`)
- **Devise::Test::IntegrationHelpers** included for all integration tests
- **Parallel execution** enabled (`parallelize(workers: :number_of_processors)`)
- **System tests** use Capybara + Selenium (Chrome)

### Running Tests

```bash
bin/rails test                           # all unit + integration tests
bin/rails test test/models/              # model tests only
bin/rails test test/controllers/         # controller tests only
bin/rails test:system                    # system tests (browser)
bin/rails test test/path/to/file.rb      # single file
bin/rails test test/path/to/file.rb:42   # single test by line number
```

### Test Organization

```
test/
├── fixtures/           # YAML test data
├── models/             # Unit tests for models
├── controllers/        # Integration tests for web + API controllers
├── system/             # Browser-based end-to-end tests
├── services/           # Unit tests for service objects (planned)
└── test_helper.rb      # Shared setup, Devise helpers
```

## Code Quality

### Linting (Rubocop)

```bash
bundle exec rubocop           # check for offenses
bundle exec rubocop -A         # auto-correct
```

Config in `.rubocop.yml`. Known pre-existing offenses are tracked in `.rubocop_todo.yml` — fix these as you touch the relevant code.

### Security (Brakeman)

```bash
bundle exec brakeman --no-pager
```

Static analysis for common Rails security vulnerabilities (XSS, SQL injection, mass assignment, etc.).

## CI / GitHub Actions

Three parallel jobs run on every push/PR to `main` (defined in `.github/workflows/ci.yml`):

1. **test** — `bin/rails test` (Minitest + SimpleCov)
2. **lint** — `bundle exec rubocop`
3. **security** — `bundle exec brakeman`

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `ISBNDB_API_KEY` | ISBNdb API access (set to `test_dummy_key` in test) |
| `ANTHROPIC_API_KEY` | Claude API access for `BookClassifier` / `books:classify` |
| `S3_BUCKET` | Production image storage bucket |
| `AWS_REGION` | AWS region for S3 |
| `ACCESS_KEY` | AWS access key |
| `SECRET_KEY` | AWS secret key |

## Work Tracking

This project uses the **BOOK** namespace in WCP (Work Context Protocol) for task tracking. Reference callsigns (e.g., `BOOK-1`) in commit messages and PR descriptions for traceability.

## Conventions

- **TDD always** — write failing tests first, then implementation
- RESTful resource routing throughout
- User-scoped data access in all controllers (never expose other users' data)
- Service objects live in `app/models/` (not a separate `app/services/` dir)
- JSON API responses use inline hash construction (no serializer gem)
- Commit messages reference WCP callsigns when applicable (e.g., `BOOK-1`)
- `annotate` gem keeps schema comments in model files
