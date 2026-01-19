# iOS API Authentication Overview

## Current State

Reader already has a basic API authentication scheme suitable for iOS:

### Existing Endpoints

**Login:**
```
POST /api/v1/sessions
Content-Type: application/json

{ "email": "user@example.com", "password": "secret" }

Response (200):
{ "user_id": 123, "api_key": "abc123..." }

Response (401):
{ "error": "Invalid credentials" }
```

**Authenticated Request:**
```
GET /api/v1/books?api_key=abc123...&user_id=123

Response:
{ "user": "user@example.com", "books": [...], "book_count": 5 }
```

### How It Works

1. User model has `api_key` field (40-char hex, generated on user creation)
2. Login validates credentials via Devise, returns `user_id` + `api_key`
3. API controllers check both params with `valid_api_user?` before_action
4. Keys are persistent (no expiration)

---

## iOS Implementation Guide

### 1. Keychain Storage

Store credentials securely after login:

```swift
// After successful login response
KeychainHelper.save(key: "api_key", value: response.apiKey)
KeychainHelper.save(key: "user_id", value: String(response.userId))
```

### 2. API Client

```swift
class ReaderAPIClient {
    let baseURL = "https://reader.example.com"

    private var apiKey: String? {
        KeychainHelper.get(key: "api_key")
    }

    private var userId: String? {
        KeychainHelper.get(key: "user_id")
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/api/v1/sessions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["email": email, "password": password])

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }

    func getBooks() async throws -> BooksResponse {
        guard let apiKey, let userId else { throw AuthError.notLoggedIn }

        var components = URLComponents(string: "\(baseURL)/api/v1/books")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "user_id", value: userId)
        ]

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        return try JSONDecoder().decode(BooksResponse.self, from: data)
    }
}
```

### 3. Logout

```swift
func logout() {
    KeychainHelper.delete(key: "api_key")
    KeychainHelper.delete(key: "user_id")
}
```

---

## Recommended Enhancements

### Short-term (Optional)

1. **Move to Headers** - Use `Authorization: Bearer <api_key>` header instead of query params
2. **Add User-Agent** - Track iOS app version for debugging

### Medium-term (If Needed)

1. **Token Expiration** - Add `api_key_expires_at` field, refresh flow
2. **Device Registration** - Track devices, enable push notifications
3. **Rate Limiting** - Protect against brute force

### Not Recommended

- JWT tokens (overkill for this use case)
- OAuth 2.0 (unnecessary complexity for single-app auth)

---

## Tech Stack Reference

| Component | Technology |
|-----------|------------|
| Framework | Rails 7.0.4 |
| Ruby | 3.1.2 |
| Database | SQLite3 |
| Auth | Devise + API key |
| API Format | JSON (jbuilder) |

---

## Files Reference

| Purpose | Location |
|---------|----------|
| Sessions Controller | `app/controllers/api/v1/sessions_controller.rb` |
| Books Controller | `app/controllers/api/v1/books_controller.rb` |
| User Model | `app/models/user.rb` |
| Routes | `config/routes.rb` |
