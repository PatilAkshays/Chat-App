import SwiftUI

struct MainFlowView: View {
    @ObservedObject var appCoordinator: AppCoordinator

    var body: some View {
        TabView(selection: $appCoordinator.selectedTab) {
            NavigationStack(path: $appCoordinator.chatPath) {
                ChatListView(viewModel: appCoordinator.mainCoordinator.chatListCoordinator.makeViewModel())
                    .navigationDestination(for: ChatRoute.self) { route in
                        switch route {
                        case .chat(let conversation):
                            ChatView(viewModel: appCoordinator.mainCoordinator.chatListCoordinator.makeChatViewModel(conversation: conversation))
                        }
                    }
            }
            .tabItem { Label("Chats", systemImage: "message") }
            .tag(MainTab.chats)

            ProfileView(viewModel: appCoordinator.mainCoordinator.profileCoordinator.makeViewModel())
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(MainTab.profile)

            SettingsView(logout: { appCoordinator.mainCoordinator.settingsCoordinator.onLogout?() })
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(MainTab.settings)
        }
    }
}
