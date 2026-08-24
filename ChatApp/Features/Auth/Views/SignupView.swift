import SwiftUI

struct SignupView: View {
    @StateObject var viewModel: SignupViewModel
    let showLogin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer(minLength: 24)
            VStack(alignment: .leading, spacing: 8) {
                Text("Create Account")
                    .font(.largeTitle.bold())
                Text("Start messaging with a secure Chat App profile.")
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 16) {
                AppTextField(title: "Name", text: $viewModel.name)
                AppTextField(title: "Email", text: $viewModel.email, keyboardType: .emailAddress)
                AppTextField(title: "Password", text: $viewModel.password, isSecure: true)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            PrimaryButton(title: "Sign Up", isLoading: viewModel.isLoading, action: viewModel.signup)

            Button("Already have an account? Log in", action: showLogin)
                .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding(24)
        .navigationBarHidden(true)
    }
}
