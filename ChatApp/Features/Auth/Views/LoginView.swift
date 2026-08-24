import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    let showSignup: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer(minLength: 24)
            VStack(alignment: .leading, spacing: 8) {
                Text("Chat App")
                    .font(.largeTitle.bold())
                Text("Sign in to continue your conversations.")
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 16) {
                AppTextField(title: "Email", text: $viewModel.email, keyboardType: .emailAddress)
                AppTextField(title: "Password", text: $viewModel.password, isSecure: true)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            PrimaryButton(title: "Log In", isLoading: viewModel.isLoading, action: viewModel.login)

            Button("Create an account", action: showSignup)
                .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding(24)
        .navigationBarHidden(true)
    }
}
