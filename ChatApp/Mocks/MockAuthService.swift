import Foundation

actor MockAuthService: AuthServiceProtocol {
    private var session: AuthSession?

    func login(email: String, password: String) async throws -> AuthSession {
        try AuthService.validate(email: email, password: password)
        let session = AuthSession(token: "mock-token", user: MockData.currentUser)
        self.session = session
        return session
    }

    func signup(name: String, email: String, password: String) async throws -> AuthSession {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw AuthError.missingName }
        try AuthService.validate(email: email, password: password)
        let session = AuthSession(token: "mock-token", user: User(id: "current-user", name: name, email: email, profileImageURL: nil, isOnline: true))
        self.session = session
        return session
    }

    func currentSession() async throws -> AuthSession? {
        session
    }

    func logout() async throws {
        session = nil
    }
}
