import Foundation

/// Global constants used for configuring the Supabase and ISBNdb services.
enum AppConstants {
    /// Base URL of the Supabase instance. Replace the placeholder before running the app.
    static let supabaseURL = URL(string: "https://your-supabase-instance.supabase.co")!

    /// Public anon key for the Supabase instance.
    static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"

    /// API key for [ISBNdb](https://isbndb.com/). Used to enrich book metadata when adding a new book.
    static let isbnDbAPIKey = "YOUR_ISBNDB_API_KEY"
}
