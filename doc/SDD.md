# Reader - Software Design Document

> Current architecture as of January 2026

---

## System Overview

Reader is a Ruby on Rails 7 monolith serving both a web interface and JSON API. Data is stored in SQLite with Active Storage for images and Action Text for rich content.

---

## Technology Stack

| Layer | Technology |
|-------|------------|
| Framework | Rails 7.0.4 |
| Language | Ruby 3.1.2 |
| Database | SQLite3 |
| Web Server | Puma 5.x |
| Authentication | Devise |
| Search | Ransack |
| Pagination | Pagy |
| Rich Text | Action Text |
| File Storage | Active Storage |
| External API | ISBNdb (via isbndb-ruby gem) |
| Frontend | Turbo, Stimulus, Bootstrap 5 |

---

## Data Model

### Entity Relationship Diagram

```
┌─────────┐       ┌─────────┐       ┌──────────────────┐
│  User   │───┬──▶│  Shelf  │◀──────│      Book        │
└─────────┘   │   └─────────┘       └──────────────────┘
     │        │                              │
     │        └── default_shelf              │
     │                                       ▼
     │                            ┌──────────────────┐
     └───────────────────────────▶│ IsbnSearchResult │
                                  └──────────────────┘
```

### Tables

**users**
| Column | Type | Notes |
|--------|------|-------|
| id | integer | PK |
| email | string | unique, required |
| encrypted_password | string | Devise |
| api_key | string | unique, 40-char hex |
| shelf_id | integer | FK to default shelf |

**shelves**
| Column | Type | Notes |
|--------|------|-------|
| id | integer | PK |
| name | string | required |
| user_id | integer | FK |

**books**
| Column | Type | Notes |
|--------|------|-------|
| id | integer | PK |
| title | string | |
| author | string | |
| isbn | string | |
| shelf_id | integer | FK |
| user_id | integer | FK |

**isbn_search_results**
| Column | Type | Notes |
|--------|------|-------|
| id | integer | PK |
| book_id | integer | FK |
| title | string | |
| authors | string | |
| isbn13 | string | |
| isbn10 | string | |
| image_url | string | |

**Additional Tables**: active_storage_blobs, active_storage_attachments, action_text_rich_texts

---

## Architecture

### Directory Structure

```
app/
├── controllers/
│   ├── application_controller.rb
│   ├── books_controller.rb
│   ├── shelves_controller.rb
│   ├── isbn_searches_controller.rb
│   ├── assignments_controller.rb
│   ├── book_searches_controller.rb
│   ├── defaults_controller.rb
│   └── api/v1/
│       ├── sessions_controller.rb
│       ├── books_controller.rb
│       └── shelves_controller.rb
├── models/
│   ├── user.rb
│   ├── book.rb
│   ├── shelf.rb
│   ├── isbn_search_result.rb
│   ├── isbn_searcher.rb      # Service object
│   ├── isbn_assigner.rb      # Service object
│   ├── good_reads_importer.rb
│   └── sofa_importer.rb
└── views/
    ├── books/
    ├── shelves/
    └── api_docs/
```

### Request Flow

```
┌──────────┐    ┌─────────┐    ┌────────────┐    ┌───────┐
│  Client  │───▶│ Routes  │───▶│ Controller │───▶│ Model │
└──────────┘    └─────────┘    └────────────┘    └───────┘
                                     │                │
                                     ▼                ▼
                               ┌──────────┐    ┌──────────┐
                               │   View   │    │ Database │
                               └──────────┘    └──────────┘
```

---

## Authentication

### Web (Devise)

- Session-based authentication
- `before_action :authenticate_user!` on protected controllers
- Standard Devise modules: database_authenticatable, registerable, recoverable, rememberable, validatable

### API

- Query parameter authentication: `?api_key=...&user_id=...`
- API key generated on user creation: `SecureRandom.hex(20)`
- Validation via `before_action :valid_api_user?`

```ruby
def valid_api_user?
  return false unless params[:api_key] && params[:user_id]
  @current_user = User.find_by(id: params[:user_id], api_key: params[:api_key])
  @current_user.present?
end
```

---

## API Endpoints

### POST /api/v1/sessions

**Request:**
```json
{ "email": "user@example.com", "password": "secret" }
```

**Response (200):**
```json
{ "user_id": 123, "api_key": "abc123..." }
```

### GET /api/v1/shelves

**Response (200):**
```json
{
  "user": "user@example.com",
  "shelves": [
    { "id": 1, "name": "To Read", "book_count": 12 }
  ]
}
```

### GET /api/v1/books

**Response (200):**
```json
{
  "user": "user@example.com",
  "books": [
    { "id": 1, "title": "...", "author": "...", "isbn": "...", "shelf_id": 1 }
  ],
  "book_count": 47
}
```

---

## Service Objects

### IsbnSearcher

Queries ISBNdb API for book metadata.

```ruby
IsbnSearcher.new(book).search
# => Creates IsbnSearchResult records
```

### IsbnAssigner

Applies selected ISBN result to book.

```ruby
IsbnAssigner.new(book, isbn_search_result).assign
# => Updates book fields, downloads cover image
```

### GoodReadsImporter

Imports GoodReads CSV export with shelf mapping.

```ruby
GoodReadsImporter.new(user, csv_file).import!
# => Creates shelves and books, imports reviews
```

---

## Key Design Decisions

1. **Monolith Architecture**: Single Rails app serves web + API
2. **SQLite Database**: Simple deployment, sufficient for single-user scale
3. **Service Objects**: Business logic extracted from models/controllers
4. **Active Storage**: Unified file handling for cover images
5. **Action Text**: Rich text editing for book comments
6. **Query Param Auth**: Simple API authentication without tokens/headers

---

## Dependencies

### Production Gems

| Gem | Purpose |
|-----|---------|
| rails ~7.0.4 | Framework |
| devise | Authentication |
| pagy | Pagination |
| ransack | Search/filtering |
| isbndb-ruby | ISBN API client |
| image_processing | Cover image handling |
| redcarpet | Markdown rendering |

### Frontend

| Technology | Purpose |
|------------|---------|
| Turbo | Fast navigation |
| Stimulus | JS behaviors |
| Bootstrap 5 | CSS framework |
| Importmap | JS bundling |
