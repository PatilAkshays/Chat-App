import Combine
import Foundation

@MainActor
final class MainCoordinator: ObservableObject, Coordinator {
    let chatListCoordinator: ChatListCoordinator
    let profileCoordinator: ProfileCoordinator
    let settingsCoordinator: SettingsCoordinator

    var onLogout: (() -> Void)?
    var onOpenChat: ((Conversation) -> Void)?

    init(container: DIContainer) {
        chatListCoordinator = ChatListCoordinator(container: container)
        profileCoordinator = ProfileCoordinator(container: container)
        settingsCoordinator = SettingsCoordinator()
        chatListCoordinator.onOpenChat = { [weak self] conversation in
            self?.onOpenChat?(conversation)
        }
        settingsCoordinator.onLogout = { [weak self] in
            self?.onLogout?()
        }
    }

    func start() {}
}
