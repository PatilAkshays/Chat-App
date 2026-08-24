import Combine
import Foundation

@MainActor
final class AuthCoordinator: ObservableObject, Coordinator {
    @Published var route: AuthRoute = .login
    var onAuthenticated: ((AuthSession) -> Void)?

    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func start() {
        route = .login
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(repository: container.authRepository, onAuthenticated: { [weak self] session in
            self?.onAuthenticated?(session)
        })
    }

    func makeSignupViewModel() -> SignupViewModel {
        SignupViewModel(repository: container.authRepository, onAuthenticated: { [weak self] session in
            self?.onAuthenticated?(session)
        })
    }

    func showSignup() {
        route = .signup
    }

    func showLogin() {
        route = .login
    }
}
