import Foundation

enum AuthError: LocalizedError, Equatable {
    case invalidEmail
    case invalidPassword
    case missingName
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Enter a valid email address."
        case .invalidPassword:
            return "Password must be at least 8 characters."
        case .missingName:
            return "Enter your name."
        case .invalidCredentials:
            return "The email or password is incorrect."
        }
    }
}

protocol AuthServiceProtocol: Sendable {
    func login(email: String, password: String) async throws -> AuthSession
    func signup(name: String, email: String, password: String) async throws -> AuthSession
    func currentSession() async throws -> AuthSession?
    func logout() async throws
}

final class AuthService: AuthServiceProtocol {
    private let apiClient: APIClientProtocol
    private let sessionStore: SessionStoreProtocol

    init(apiClient: APIClientProtocol, sessionStore: SessionStoreProtocol) {
        self.apiClient = apiClient
        self.sessionStore = sessionStore
    }

    func login(email: String, password: String) async throws -> AuthSession {
        try Self.validate(email: email, password: password)
        let session: AuthSession = try await apiClient.request(endpoint: Endpoint(path: "/auth/login", method: .post, body: LoginRequest(email: email, password: password)))
        try sessionStore.save(session: session)
        return session
    }

    func signup(name: String, email: String, password: String) async throws -> AuthSession {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw AuthError.missingName }
        try Self.validate(email: email, password: password)
        let session: AuthSession = try await apiClient.request(endpoint: Endpoint(path: "/auth/signup", method: .post, body: SignupRequest(name: name, email: email, password: password)))
        try sessionStore.save(session: session)
        return session
    }

    func currentSession() async throws -> AuthSession? {
        try sessionStore.loadSession()
    }

    func logout() async throws {
        try sessionStore.clearSession()
    }

    static func validate(email: String, password: String) throws {
        guard email.contains("@"), email.contains(".") else { throw AuthError.invalidEmail }
        guard password.count >= 8 else { throw AuthError.invalidPassword }
    }
}

private struct LoginRequest: Encodable {
    let email: String
    let password: String
}

private struct SignupRequest: Encodable {
    let name: String
    let email: String
    let password: String
}
