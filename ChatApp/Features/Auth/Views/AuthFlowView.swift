import SwiftUI

struct AuthFlowView: View {
    @ObservedObject var coordinator: AuthCoordinator

    var body: some View {
        NavigationStack {
            Group {
                switch coordinator.route {
                case .login:
                    LoginView(viewModel: coordinator.makeLoginViewModel(), showSignup: coordinator.showSignup)
                case .signup:
                    SignupView(viewModel: coordinator.makeSignupViewModel(), showLogin: coordinator.showLogin)
                }
            }
        }
        .onAppear { coordinator.start() }
    }
}
