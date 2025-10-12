import Foundation
import Supabase

struct SupabaseClientManager {
    let client: SupabaseClient

    init(url: URL = AppConstants.supabaseURL, key: String = AppConstants.supabaseAnonKey) {
        self.client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }
}
