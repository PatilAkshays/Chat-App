import Foundation

actor MockChatService: ChatServiceProtocol {
    private var storedMessages = MockData.messages
    private let continuation: AsyncStream<SocketEvent>.Continuation
    private let stream: AsyncStream<SocketEvent>

    init() {
        var continuation: AsyncStream<SocketEvent>.Continuation!
        self.stream = AsyncStream { continuation = $0 }
        self.continuation = continuation
    }

    func conversations() async throws -> [Conversation] {
        try await Task.sleep(nanoseconds: 250_000_000)
        return MockData.conversations
    }

    func messages(conversationId: String, before date: Date?) async throws -> [Message] {
        var messages = storedMessages[conversationId] ?? []
        if let date {
            messages = messages.filter { $0.createdAt < date }
        }
        return messages.sorted { $0.createdAt < $1.createdAt }
    }

    func sendText(_ text: String, conversationId: String, receiverId: String) async throws -> Message {
        let message = Message(id: UUID().uuidString, senderId: "current-user", receiverId: receiverId, text: text, imageURL: nil, createdAt: Date(), status: .sent)
        storedMessages[conversationId, default: []].append(message)
        continuation.yield(.messageReceived(message))
        return message
    }

    func sendTyping(conversationId: String, userId: String, isTyping: Bool) async throws {
        continuation.yield(.typing(conversationId: conversationId, userId: userId, isTyping: isTyping))
    }

    func socketEvents() async -> AsyncStream<SocketEvent> {
        stream
    }
}
