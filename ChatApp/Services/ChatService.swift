import Foundation

protocol ChatServiceProtocol: Sendable {
    func conversations() async throws -> [Conversation]
    func messages(conversationId: String, before date: Date?) async throws -> [Message]
    func sendText(_ text: String, conversationId: String, receiverId: String) async throws -> Message
    func sendTyping(conversationId: String, userId: String, isTyping: Bool) async throws
    func socketEvents() async -> AsyncStream<SocketEvent>
}

final class ChatService: ChatServiceProtocol {
    private let apiClient: APIClientProtocol
    private let socketManager: SocketManaging

    init(apiClient: APIClientProtocol, socketManager: SocketManaging) {
        self.apiClient = apiClient
        self.socketManager = socketManager
    }

    func conversations() async throws -> [Conversation] {
        try await apiClient.request(endpoint: Endpoint(path: "/conversations"))
    }

    func messages(conversationId: String, before date: Date?) async throws -> [Message] {
        let queryItems = date.map { [URLQueryItem(name: "before", value: ISO8601DateFormatter().string(from: $0))] } ?? []
        return try await apiClient.request(endpoint: Endpoint(path: "/conversations/\(conversationId)/messages", queryItems: queryItems))
    }

    func sendText(_ text: String, conversationId: String, receiverId: String) async throws -> Message {
        let message = Message(id: UUID().uuidString, senderId: "current-user", receiverId: receiverId, text: text, imageURL: nil, createdAt: Date(), status: .sending)
        try await socketManager.send(message: message)
        return Message(id: message.id, senderId: message.senderId, receiverId: message.receiverId, text: message.text, imageURL: message.imageURL, createdAt: message.createdAt, status: .sent)
    }

    func sendTyping(conversationId: String, userId: String, isTyping: Bool) async throws {
        try await socketManager.sendTyping(conversationId: conversationId, userId: userId, isTyping: isTyping)
    }

    func socketEvents() async -> AsyncStream<SocketEvent> {
        await socketManager.events()
    }
}
