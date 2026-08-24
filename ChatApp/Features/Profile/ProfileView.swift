import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                AvatarView(user: viewModel.user, size: 96)
                Text(viewModel.user?.name ?? "ChatApp User")
                    .font(.title2.bold())
                Text(viewModel.user?.email ?? "")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(24)
            .navigationTitle("Profile")
            .onAppear { viewModel.load() }
        }
    }
}
