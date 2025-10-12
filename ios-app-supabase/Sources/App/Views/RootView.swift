import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.appEnvironment) private var environment

    var body: some View {
        switch appViewModel.state {
        case .loading:
            ProgressView("Loading…")
                .progressViewStyle(.circular)
        case .unauthenticated:
            AuthView(viewModel: AuthViewModel(authService: environment.authService))
        case .authenticated(let user):
            MainTabView(user: user)
                .environment(\.appEnvironment, environment)
                .environmentObject(appViewModel)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppViewModel(environment: .preview))
            .environment(\.appEnvironment, .preview)
    }
}
