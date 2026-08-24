import Combine
import Foundation

@MainActor
final class ChatListCoordinator: ObservableObject, Coordinator {
    var onOpenChat: ((Conversation) -> Void)?
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func start() {}

    func makeViewModel() -> ChatListViewModel {
        ChatListViewModel(repository: container.chatRepository, onOpenChat: { [weak self] conversation in
            self?.onOpenChat?(conversation)
        })
    }

    func makeChatViewModel(conversation: Conversation) -> ChatViewModel {
        ChatViewModel(conversation: conversation, service: container.chatService, repository: container.chatRepository)
    }
}

@MainActor
final class ProfileCoordinator: ObservableObject, Coordinator {
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func start() {}

    func makeViewModel() -> ProfileViewModel {
        ProfileViewModel(repository: container.authRepository)
    }
}

@MainActor
final class SettingsCoordinator: ObservableObject, Coordinator {
    var onLogout: (() -> Void)?

    func start() {}
}
