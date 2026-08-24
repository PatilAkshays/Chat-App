import Combine
import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = "akshay@example.com"
    @Published var password = "password123"
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let repository: AuthRepositoryProtocol
    private let onAuthenticated: (AuthSession) -> Void

    init(repository: AuthRepositoryProtocol, onAuthenticated: @escaping (AuthSession) -> Void) {
        self.repository = repository
        self.onAuthenticated = onAuthenticated
    }

    func login() {
        errorMessage = nil
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                let session = try await repository.login(email: email, password: password)
                onAuthenticated(session)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
