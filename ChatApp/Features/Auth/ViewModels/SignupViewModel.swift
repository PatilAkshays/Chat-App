import Combine
import Foundation

@MainActor
final class SignupViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let repository: AuthRepositoryProtocol
    private let onAuthenticated: (AuthSession) -> Void

    init(repository: AuthRepositoryProtocol, onAuthenticated: @escaping (AuthSession) -> Void) {
        self.repository = repository
        self.onAuthenticated = onAuthenticated
    }

    func signup() {
        errorMessage = nil
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                let session = try await repository.signup(name: name, email: email, password: password)
                onAuthenticated(session)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
