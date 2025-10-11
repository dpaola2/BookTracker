import Foundation
import Combine

struct AppEnvironment {
    let authService: AuthServiceProtocol
    let libraryService: LibraryServiceProtocol
    let isbnService: ISBNdbServicing

    static var live: AppEnvironment {
        let clientManager = SupabaseClientManager()
        let authService = SupabaseAuthService(client: clientManager.client)
        let libraryService = SupabaseLibraryService(client: clientManager.client)
        let isbnService = ISBNdbService()
        return AppEnvironment(
            authService: authService,
            libraryService: libraryService,
            isbnService: isbnService
        )
    }

    static var preview: AppEnvironment {
        let previewService = PreviewSupabaseService()
        return AppEnvironment(
            authService: previewService,
            libraryService: previewService,
            isbnService: PreviewISBNdbService()
        )
    }
}

private struct AppEnvironmentKey: EnvironmentKey {
    static var defaultValue: AppEnvironment = .preview
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
