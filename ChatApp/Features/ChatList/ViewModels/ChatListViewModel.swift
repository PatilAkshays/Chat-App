import Combine
import Foundation

@MainActor
final class ChatListViewModel: ObservableObject {
    @Published private(set) var conversations: [Conversation] = []
    @Published var searchText = ""
    @Published private(set) var isLoading = false
    @Published private(set) var isRefreshing = false
    @Published var errorMessage: String?

    private let repository: ChatRepositoryProtocol
    private let onOpenChat: (Conversation) -> Void

    init(repository: ChatRepositoryProtocol, onOpenChat: @escaping (Conversation) -> Void) {
        self.repository = repository
        self.onOpenChat = onOpenChat
    }

    var filteredConversations: [Conversation] {
        guard !searchText.isEmpty else { return conversations }
        return conversations.filter { conversation in
            conversation.participants.contains { user in
                user.name.localizedCaseInsensitiveContains(searchText) || user.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var isEmpty: Bool {
        !isLoading && filteredConversations.isEmpty
    }

    func load() {
        guard conversations.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        Task {
            defer { isLoading = false }
            do {
                conversations = try await repository.loadConversations()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func refresh() async {
        isRefreshing = true
        errorMessage = nil
        defer { isRefreshing = false }
        do {
            conversations = try await repository.refreshConversations()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func retry() {
        conversations = []
        load()
    }

    func open(_ conversation: Conversation) {
        onOpenChat(conversation)
    }
}
