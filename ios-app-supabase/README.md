# BookTracker Supabase iOS App

This directory contains a SwiftUI iOS application that integrates with Supabase to manage book shelves and books. The project is structured as a Swift Package to simplify sharing inside this repository. Open the package in Xcode (File → Open Package) to run the previews or create an iOS app target.

## Features
- Supabase authentication (email/password) and session persistence
- Shelves list with navigation to books in each shelf
- All books tab with search
- Book detail view with metadata
- Add new book flow with ISBN lookup against ISBNdb
- MVVM architecture with dependency-injected services
- SwiftUI previews for every screen using in-memory sample data

## Setup
1. Install dependencies with Swift Package Manager by opening the package in Xcode. The project depends on [`supabase-swift`](https://github.com/supabase-community/supabase-swift).
2. Create a new Supabase project (or reuse the production project) and obtain the URL and anon/public key.
3. Copy `.env.example` to `.env` and fill in the Supabase and ISBNdb credentials. These values are read by the sample `Configuration.plist` for local development.
4. Ensure your Supabase database has the following tables and relationships:
   - `shelves`: `id` (uuid, primary key), `name` (text), `description` (text), `created_at` (timestamp)
   - `books`: `id` (uuid, primary key), `title` (text), `author` (text), `isbn` (text), `notes` (text), `shelf_id` (uuid, foreign key to `shelves.id`), `cover_url` (text), `created_at` (timestamp)
   - Row Level Security policies that allow authenticated users to read/write their data.
5. Configure Storage bucket in Supabase if you need to store cover images (optional).
6. Import existing production books by running the provided Supabase SQL/Edge function or using the `SupabaseImportService` (see `Utilities/ProductionImport.md`).

## Running
- The `BookTrackerSupabaseApp` struct is the entry point. Add an iOS application target in Xcode that depends on the `BookTrackerSupabase` library.
- Update `AppConstants.swift` with your Supabase URL, anon key, and ISBNdb API key. For security, consider loading these from a plist or using environment variables via Xcode build settings.

## Testing & Previews
All views include SwiftUI previews that rely on `PreviewSupabaseService` which mimics network calls.

## Directory Structure
```
ios-app-supabase/
├── Package.swift
├── README.md
└── Sources
    └── App
        ├── BookTrackerSupabaseApp.swift
        ├── Models
        ├── Services
        ├── Utilities
        ├── ViewModels
        └── Views
```
