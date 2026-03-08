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

## Testing

### Framework & Setup

- **Minitest** with Rails test helpers
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

### Test Philosophy

Follow **Sandi Metz's testing principles** and **SOLID design**:

1. **Test the public interface, not implementation details.** Tests should verify what an object does (messages sent/received), not how it does it internally.
2. **Test incoming messages for return values and side effects.** If a public method returns a value, assert the value. If it causes a side effect, assert the side effect.
3. **Don't test outgoing query messages.** If your object sends a message to a collaborator and doesn't care about the return value's side effects, don't test that the message was sent.
4. **Test outgoing command messages by asserting they are sent.** Use mocks/expectations only for commands to collaborators that cause side effects elsewhere.
5. **Don't test private methods.** They are implementation details. If they break, a public interface test should catch it.
6. **Each test should have a single assertion concept.** One logical assertion per test, named descriptively.

#### SOLID in Practice

- **Single Responsibility:** Each class does one thing. Service objects (`IsbnSearcher`, `IsbnAssigner`) extract behavior from controllers.
- **Open/Closed:** Prefer adding new service objects or concerns over modifying existing ones.
- **Dependency Inversion:** Service objects accept dependencies (e.g., book, search result) rather than finding them internally.
- **Interface Segregation:** API controllers and web controllers are separate hierarchies with different auth strategies.

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

## CI / GitHub Actions

Tests run on every push and pull request via GitHub Actions. The workflow is defined in `.github/workflows/ci.yml`.

```bash
# CI runs the equivalent of:
bin/rails db:setup
bin/rails test
```

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `ISBNDB_API_KEY` | ISBNdb API access (set to `test_dummy_key` in test) |
| `S3_BUCKET` | Production image storage bucket |
| `AWS_REGION` | AWS region for S3 |
| `ACCESS_KEY` | AWS access key |
| `SECRET_KEY` | AWS secret key |

## Conventions

- RESTful resource routing throughout
- User-scoped data access in all controllers (never expose other users' data)
- Service objects live in `app/models/` (not a separate `app/services/` dir)
- JSON API responses use inline hash construction (no serializer gem)
- Commit messages reference WCP callsigns when applicable (e.g., `BOOK-1`)
- `annotate` gem keeps schema comments in model files
