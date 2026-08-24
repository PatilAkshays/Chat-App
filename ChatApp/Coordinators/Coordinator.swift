import Foundation

protocol Coordinator: AnyObject {
    func start()
}

enum AppFlow: Equatable {
    case launching
    case auth
    case main
}

enum AuthRoute: Hashable {
    case login
    case signup
}

enum MainTab: Hashable {
    case chats
    case profile
    case settings
}

enum ChatRoute: Hashable {
    case chat(conversation: Conversation)
}
