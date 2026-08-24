import Combine
import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published var inputText = ""
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingOlderMessages = false
    @Published private(set) var isTyping = false
    @Published var errorMessage: String?

    let conversation: Conversation
    private let service: ChatServiceProtocol
    private let repository: ChatRepositoryProtocol
    private var eventTask: Task<Void, Never>?

    init(conversation: Conversation, service: ChatServiceProtocol, repository: ChatRepositoryProtocol) {
        self.conversation = conversation
        self.service = service
        self.repository = repository
    }

    deinit {
        eventTask?.cancel()
    }

    func load() {
        guard messages.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        Task {
            defer { isLoading = false }
            do {
                messages = try await repository.loadMessages(conversationId: conversation.id, before: nil)
                observeSocketEvents()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func loadOlderMessages() async {
        guard !isLoadingOlderMessages else { return }
        isLoadingOlderMessages = true
        defer { isLoadingOlderMessages = false }
        do {
            let older = try await repository.loadMessages(conversationId: conversation.id, before: messages.first?.createdAt)
            let newMessages = older.filter { message in !messages.contains(where: { $0.id == message.id }) }
            messages.insert(contentsOf: newMessages, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func send() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty, let receiverId = conversation.participants.first?.id else { return }
        inputText = ""
        Task {
            do {
                let message = try await repository.sendText(trimmedText, conversationId: conversation.id, receiverId: receiverId)
                append(message)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func updateTyping(isTyping: Bool) {
        guard let userId = conversation.participants.first?.id else { return }
        Task { try? await repository.sendTyping(conversationId: conversation.id, userId: userId, isTyping: isTyping) }
    }

    func retry() {
        messages = []
        load()
    }

    private func observeSocketEvents() {
        guard eventTask == nil else { return }
        eventTask = Task { [weak self] in
            guard let self else { return }
            let events = await service.socketEvents()
            for await event in events {
                guard !Task.isCancelled else { break }
                switch event {
                case .messageReceived(let message):
                    append(message)
                case .typing(let conversationId, _, let isTyping) where conversationId == conversation.id:
                    self.isTyping = isTyping
                default:
                    break
                }
            }
        }
    }

    private func append(_ message: Message) {
        guard !messages.contains(where: { $0.id == message.id }) else { return }
        messages.append(message)
    }
}
