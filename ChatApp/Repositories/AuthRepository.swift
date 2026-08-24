import Foundation

protocol AuthRepositoryProtocol: Sendable {
    func login(email: String, password: String) async throws -> AuthSession
    func signup(name: String, email: String, password: String) async throws -> AuthSession
    func currentSession() async throws -> AuthSession?
    func logout() async throws
}

final class AuthRepository: AuthRepositoryProtocol {
    private let service: AuthServiceProtocol

    init(service: AuthServiceProtocol) {
        self.service = service
    }

    func login(email: String, password: String) async throws -> AuthSession {
        try await service.login(email: email, password: password)
    }

    func signup(name: String, email: String, password: String) async throws -> AuthSession {
        try await service.signup(name: name, email: email, password: password)
    }

    func currentSession() async throws -> AuthSession? {
        try await service.currentSession()
    }

    func logout() async throws {
        try await service.logout()
    }
}
