import Foundation
import Combine

protocol AuthServiceProtocol {
    var userPublisher: AnyPublisher<AppUser?, Never> { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() async throws
}
