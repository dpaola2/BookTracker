import Foundation
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    enum FlowState {
        case loading
        case authenticated(AppUser)
        case unauthenticated
    }

    @Published private(set) var state: FlowState = .loading

    let environment: AppEnvironment

    private var cancellables = Set<AnyCancellable>()

    init(environment: AppEnvironment) {
        self.environment = environment
        observeAuthChanges()
    }

    private func observeAuthChanges() {
        environment.authService.userPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self = self else { return }
                if let user {
                    self.state = .authenticated(user)
                } else {
                    self.state = .unauthenticated
                }
            }
            .store(in: &cancellables)
    }

    func signOut() {
        Task {
            do {
                try await environment.authService.signOut()
            } catch {
                print("Sign out failed: \(error)")
            }
        }
    }
}
