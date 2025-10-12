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

## Requirements
- Xcode 15.0 or newer (Swift 5.9 toolchain)
- iOS 16.0 simulator or device minimum deployment target
- Supabase project URL + anon/public API key
- ISBNdb API key

## Setup
1. Install dependencies with Swift Package Manager by opening the package in Xcode (see the next section for detailed steps). The project depends on [`supabase-swift`](https://github.com/supabase-community/supabase-swift).
2. Create a new Supabase project (or reuse the production project) and obtain the URL and anon/public key.
3. Copy `.env.example` to `.env` and fill in the Supabase and ISBNdb credentials. These values are read by the sample `Configuration.plist` for local development.
4. Ensure your Supabase database has the following tables and relationships:
   - `shelves`: `id` (uuid, primary key), `name` (text), `description` (text), `created_at` (timestamp)
   - `books`: `id` (uuid, primary key), `title` (text), `author` (text), `isbn` (text), `notes` (text), `shelf_id` (uuid, foreign key to `shelves.id`), `cover_url` (text), `created_at` (timestamp)
   - Row Level Security policies that allow authenticated users to read/write their data.
5. Configure Storage bucket in Supabase if you need to store cover images (optional).
6. Import existing production books by running the provided Supabase SQL/Edge function or using the `SupabaseImportService` (see `Utilities/ProductionImport.md`).

## Opening the package in Xcode
1. Launch Xcode and choose **File → Open Package…**.
2. Select the `ios-app-supabase` directory from this repository. Xcode will resolve the Swift Package dependencies (Supabase).
3. After the package loads, create a new iOS App target:
   - File → New → Target… → iOS → App.
   - When prompted, set the minimum iOS version to 16.0 and choose SwiftUI + Swift as the interface/language.
   - In the target's **Frameworks, Libraries, and Embedded Content**, add the `BookTrackerSupabase` library product.
4. Set the new app target as the run destination. The entry point is `BookTrackerSupabaseApp`.

If you run into build errors after adding the target, confirm that the deployment target is iOS 16.0 or higher and that the app target links the `BookTrackerSupabase` product.

## Configuring Supabase + ISBNdb
The runtime configuration lives in `Sources/App/Utilities/AppConstants.swift`. Provide your credentials by updating the placeholder strings or by loading them from a secure source (recommended for real projects). A simple approach during development is to create a property list:

1. Duplicate `.env.example` to `.env` and fill in values for `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `ISBNDB_API_KEY`.
2. Add a new **Run Script Phase** (or use a build tool) in your Xcode target that transforms `.env` into a plist at build time, then read it inside `AppConstants`.

For production, store secrets outside of source control and inject them using Xcode build configurations or a secrets manager.

## Running
- The `BookTrackerSupabaseApp` struct is the entry point for the created app target. Run the target on an iOS 16+ simulator or device.
- Update `AppConstants.swift` with your Supabase URL, anon key, and ISBNdb API key (either hard-coded for local testing or loaded from configuration as described above).

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
