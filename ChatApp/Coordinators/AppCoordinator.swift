import Combine
import Foundation

@MainActor
final class AppCoordinator: ObservableObject, Coordinator {
    @Published private(set) var flow: AppFlow = .launching
    @Published var selectedTab: MainTab = .chats
    @Published var chatPath: [ChatRoute] = []

    let container: DIContainer
    let authCoordinator: AuthCoordinator
    let mainCoordinator: MainCoordinator

    init(container: DIContainer) {
        self.container = container
        self.authCoordinator = AuthCoordinator(container: container)
        self.mainCoordinator = MainCoordinator(container: container)
        authCoordinator.onAuthenticated = { [weak self] session in
            Task { await self?.handleAuthenticated(session: session) }
        }
        mainCoordinator.onLogout = { [weak self] in
            Task { await self?.logout() }
        }
        mainCoordinator.onOpenChat = { [weak self] conversation in
            self?.open(conversation: conversation)
        }
    }

    func start() {
        Task {
            if (try? await container.authRepository.currentSession()) != nil {
                flow = .main
            } else {
                flow = .auth
            }
        }
    }

    func handle(deepLink: AppDeepLink) {
        switch deepLink {
        case .chat:
            selectedTab = .chats
            flow = .main
        }
    }

    private func handleAuthenticated(session: AuthSession) async {
        await container.socketManager.connect(token: session.token)
        flow = .main
    }

    private func logout() async {
        try? await container.authRepository.logout()
        await container.socketManager.disconnect()
        chatPath = []
        flow = .auth
    }

    private func open(conversation: Conversation) {
        selectedTab = .chats
        chatPath.append(.chat(conversation: conversation))
    }
}
