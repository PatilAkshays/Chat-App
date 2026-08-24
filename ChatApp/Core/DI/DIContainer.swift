import Foundation

final class DIContainer {
    let apiClient: APIClientProtocol
    let socketManager: SocketManaging
    let localStore: LocalStoreProtocol
    let sessionStore: SessionStoreProtocol
    let notificationManager: NotificationManaging

    let authService: AuthServiceProtocol
    let chatService: ChatServiceProtocol
    let userService: UserServiceProtocol

    let authRepository: AuthRepositoryProtocol
    let chatRepository: ChatRepositoryProtocol
    let userRepository: UserRepositoryProtocol

    init(useMocks: Bool = true) {
        apiClient = APIClient()
        socketManager = SocketManager()
        localStore = CoreDataLocalStore()
        sessionStore = KeychainSessionStore()
        notificationManager = NotificationManager()

        if useMocks {
            authService = MockAuthService()
            chatService = MockChatService()
            userService = MockUserService()
        } else {
            authService = AuthService(apiClient: apiClient, sessionStore: sessionStore)
            chatService = ChatService(apiClient: apiClient, socketManager: socketManager)
            userService = UserService(apiClient: apiClient)
        }

        authRepository = AuthRepository(service: authService)
        chatRepository = ChatRepository(service: chatService, localStore: localStore)
        userRepository = UserRepository(service: userService, localStore: localStore)
    }
}
