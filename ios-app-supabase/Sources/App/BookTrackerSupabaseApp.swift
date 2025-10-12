import SwiftUI

@main
struct BookTrackerSupabaseApp: App {
    @StateObject private var appViewModel: AppViewModel
    private let environment: AppEnvironment

    init() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["USE_PREVIEW_ENVIRONMENT"] == "1" {
            environment = .preview
        } else {
            environment = .live
        }
        #else
        environment = .live
        #endif
        _appViewModel = StateObject(wrappedValue: AppViewModel(environment: environment))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appViewModel)
                .environment(\.appEnvironment, environment)
        }
    }
}
