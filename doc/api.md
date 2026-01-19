# API Documentation

## Authentication

All API requests require authentication using an API key and user ID.

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `api_key` | string | Your API key |
| `user_id` | integer | Your user ID |

## Endpoints

### GET /api/v1/books

Returns all books for the authenticated user.

**Request:**

```
GET /api/v1/books?api_key=YOUR_API_KEY&user_id=YOUR_USER_ID
```

**Response:**

```json
{
  "user": "user@example.com",
  "books": [
    {
      "id": 1,
      "title": "Book Title",
      "author": "Author Name",
      "isbn": "1234567890"
    }
  ],
  "book_count": 1
}
```

### POST /api/v1/sessions

Creates a new API session.

**Request:**

```
POST /api/v1/sessions
```

## Error Responses

| Status Code | Description |
|-------------|-------------|
| 401 | Invalid API key or missing credentials |
