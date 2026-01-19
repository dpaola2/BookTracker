# Reader - Product Requirements Document

> Current functionality as of January 2026

---

## Overview

Reader is a personal book tracking application. Users organize books into shelves, track reading progress, and enhance book metadata via ISBN lookup. The application provides both a web interface and a JSON API for mobile clients.

---

## User Personas

**Primary User**: Book enthusiasts who want to catalog their personal library, track what they've read, and organize books by reading status or custom categories.

---

## Features

### 1. User Authentication

| Capability | Description |
|------------|-------------|
| Registration | Email/password signup |
| Login/Logout | Session-based web auth |
| Password Reset | Email-based recovery |
| API Authentication | API key + user ID for mobile clients |

### 2. Shelf Management

| Capability | Description |
|------------|-------------|
| Create Shelf | Custom named shelves (e.g., "To Read", "Favorites") |
| View Shelves | List all shelves with book counts |
| Edit Shelf | Rename shelves |
| Delete Shelf | Remove empty or populated shelves |
| Default Shelf | Set a default shelf for new books |

### 3. Book Management

| Capability | Description |
|------------|-------------|
| Add Book | Manual entry: title, author, ISBN, cover image |
| Edit Book | Update any book field |
| Delete Book | Remove book from library |
| Move Book | Transfer book between shelves |
| Cover Image | Upload custom image or fetch via ISBN |
| Comments | Rich-text notes/reviews per book |

### 4. ISBN Lookup & Enhancement

| Capability | Description |
|------------|-------------|
| Search by Title/Author | Query ISBNdb API for matches |
| View Results | Display matching books with covers |
| Assign Result | Apply selected metadata to book |
| Auto-download Cover | Fetch cover image from ISBN result |

### 5. Book Discovery

| Capability | Description |
|------------|-------------|
| Search Library | Filter books by title, author, ISBN |
| Pagination | Browse large libraries efficiently |
| BookFinder Link | External link to purchase options |

### 6. Import

| Capability | Description |
|------------|-------------|
| GoodReads Import | CSV import with shelf mapping, reviews |
| Sofa Import | Simple CSV import (title + list) |

### 7. API Access

| Endpoint | Purpose |
|----------|---------|
| POST /api/v1/sessions | Login, receive credentials |
| GET /api/v1/shelves | List shelves with counts |
| GET /api/v1/books | List all user's books |

---

## Non-Functional Requirements

| Requirement | Implementation |
|-------------|----------------|
| Authentication | Devise (web), API key (mobile) |
| Data Isolation | All data scoped to authenticated user |
| Performance | Pagy pagination, eager loading |
| Search | Ransack gem for advanced filtering |

---

## Out of Scope (Current Version)

- Social features (sharing, following)
- Reading progress tracking (page numbers)
- Book recommendations
- Multiple users per account
- Offline support
- Push notifications
