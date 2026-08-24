import Foundation

protocol ChatRepositoryProtocol: Sendable {
    func loadConversations() async throws -> [Conversation]
    func refreshConversations() async throws -> [Conversation]
    func loadMessages(conversationId: String, before date: Date?) async throws -> [Message]
    func sendText(_ text: String, conversationId: String, receiverId: String) async throws -> Message
    func sendTyping(conversationId: String, userId: String, isTyping: Bool) async throws
    func socketEvents() async -> AsyncStream<SocketEvent>
}

final class ChatRepository: ChatRepositoryProtocol {
    private let service: ChatServiceProtocol
    private let localStore: LocalStoreProtocol

    init(service: ChatServiceProtocol, localStore: LocalStoreProtocol) {
        self.service = service
        self.localStore = localStore
    }

    func loadConversations() async throws -> [Conversation] {
        let cached = try await localStore.cachedConversations()
        if !cached.isEmpty { return cached }
        return try await refreshConversations()
    }

    func refreshConversations() async throws -> [Conversation] {
        let conversations = try await service.conversations()
        try await localStore.cache(conversations: conversations)
        return conversations
    }

    func loadMessages(conversationId: String, before date: Date?) async throws -> [Message] {
        if date == nil {
            let cached = try await localStore.cachedMessages(conversationId: conversationId)
            if !cached.isEmpty { return cached }
        }
        let messages = try await service.messages(conversationId: conversationId, before: date)
        try await localStore.cache(messages: messages, conversationId: conversationId)
        return messages
    }

    func sendText(_ text: String, conversationId: String, receiverId: String) async throws -> Message {
        let message = try await service.sendText(text, conversationId: conversationId, receiverId: receiverId)
        try await localStore.cache(messages: [message], conversationId: conversationId)
        return message
    }

    func sendTyping(conversationId: String, userId: String, isTyping: Bool) async throws {
        try await service.sendTyping(conversationId: conversationId, userId: userId, isTyping: isTyping)
    }

    func socketEvents() async -> AsyncStream<SocketEvent> {
        await service.socketEvents()
    }
}
