# API Documentation

## Authentication

All API requests require authentication using an API key and user ID, passed as request parameters. Obtain the pair via `POST /api/v1/sessions`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `api_key` | string | Your API key |
| `user_id` | integer | Your user ID |

## Endpoints

### POST /api/v1/sessions

Log in with email/password; returns the `api_key` + `user_id` pair used by all other endpoints.

### GET /api/v1/books

Returns all books for the authenticated user. Book rows include all columns, including `classification` (`"fiction"` / `"nonfiction"` / `null`) and `genres` (comma-separated string).

```
GET /api/v1/books?api_key=YOUR_API_KEY&user_id=YOUR_USER_ID
```

```json
{
  "user": "user@example.com",
  "books": [
    {
      "id": 1,
      "title": "Book Title",
      "author": "Author Name",
      "isbn": "1234567890",
      "classification": "fiction",
      "genres": "Science Fiction,Fantasy",
      "shelf_id": 3,
      "user_id": 1
    }
  ],
  "book_count": 1
}
```

### GET /api/v1/books/:id

Single book detail. `genres` is an **array** here (unlike the index, which returns the raw comma-separated column).

```json
{
  "book": {
    "id": 1,
    "title": "Book Title",
    "author": "Author Name",
    "isbn": "1234567890",
    "shelf_id": 3,
    "shelf_name": "📚 To Read",
    "classification": "fiction",
    "genres": ["Science Fiction", "Fantasy"],
    "image_url": "https://...",
    "comments": "..."
  }
}
```

### GET /api/v1/shelves

All shelves for the user, with book counts.

```json
{
  "user": "user@example.com",
  "shelves": [
    { "id": 3, "name": "📚 To Read", "book_count": 42 }
  ]
}
```

### GET /api/v1/shelves/:id

Single shelf with its books. Books carry `classification` and `genres` (array), as in book detail.

```json
{
  "user": "user@example.com",
  "shelf": {
    "id": 3,
    "name": "📚 To Read",
    "book_count": 1,
    "books": [
      {
        "id": 1,
        "title": "Book Title",
        "author": "Author Name",
        "isbn": "1234567890",
        "classification": "fiction",
        "genres": ["Science Fiction"],
        "image_url": "https://..."
      }
    ]
  }
}
```

## Error Responses

| Status Code | Description |
|-------------|-------------|
| 401 | Invalid API key or missing credentials |
| 404 | Resource not found or belongs to another user |
