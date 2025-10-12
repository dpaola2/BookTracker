import Foundation
import Combine
import Supabase

final class SupabaseAuthService: AuthServiceProtocol {
    private let client: SupabaseClient
    private let userSubject = CurrentValueSubject<AppUser?, Never>(nil)

    var userPublisher: AnyPublisher<AppUser?, Never> {
        userSubject.eraseToAnyPublisher()
    }

    init(client: SupabaseClient) {
        self.client = client
        Task { await refreshSession() }
        client.auth.onAuthStateChange { [weak self] _, session in
            guard let self else { return }
            Task { await self.publishUser(from: session?.user) }
        }
    }

    private func publishUser(from supabaseUser: User?) async {
        if let supabaseUser {
            let user = AppUser(id: supabaseUser.id.uuidString, email: supabaseUser.email ?? "")
            userSubject.send(user)
        } else {
            userSubject.send(nil)
        }
    }

    private func refreshSession() async {
        do {
            if let session = try await client.auth.session {
                await publishUser(from: session.user)
            } else {
                userSubject.send(nil)
            }
        } catch {
            userSubject.send(nil)
        }
    }

    func signIn(email: String, password: String) async throws {
        let response = try await client.auth.signIn(email: email, password: password)
        await publishUser(from: response.user)
    }

    func signUp(email: String, password: String) async throws {
        let response = try await client.auth.signUp(email: email, password: password)
        await publishUser(from: response.user)
    }

    func signOut() async throws {
        try await client.auth.signOut()
        userSubject.send(nil)
    }
}
