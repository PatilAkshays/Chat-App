import Foundation

enum SocketEvent: Sendable, Equatable {
    case connected
    case disconnected
    case messageReceived(Message)
    case typing(conversationId: String, userId: String, isTyping: Bool)
    case presence(userId: String, isOnline: Bool)
}

protocol SocketManaging: Sendable {
    func connect(token: String) async
    func disconnect() async
    func send(message: Message) async throws
    func sendTyping(conversationId: String, userId: String, isTyping: Bool) async throws
    func events() async -> AsyncStream<SocketEvent>
}

actor SocketManager: SocketManaging {
    private let url: URL
    private var task: URLSessionWebSocketTask?
    private var continuations: [UUID: AsyncStream<SocketEvent>.Continuation] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(url: URL = URL(string: "wss://api.chatapp.local/socket")!) {
        self.url = url
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func connect(token: String) async {
        disconnectCurrentTask()
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let socketTask = URLSession.shared.webSocketTask(with: request)
        task = socketTask
        socketTask.resume()
        broadcast(.connected)
        Task { await receiveLoop() }
    }

    func disconnect() async {
        disconnectCurrentTask()
        broadcast(.disconnected)
    }

    func send(message: Message) async throws {
        let payload = SocketPayload(type: "message", message: message, conversationId: nil, userId: nil, isTyping: nil, isOnline: nil)
        try await send(payload: payload)
    }

    func sendTyping(conversationId: String, userId: String, isTyping: Bool) async throws {
        let payload = SocketPayload(type: "typing", message: nil, conversationId: conversationId, userId: userId, isTyping: isTyping, isOnline: nil)
        try await send(payload: payload)
    }

    func events() async -> AsyncStream<SocketEvent> {
        AsyncStream { continuation in
            let id = UUID()
            continuations[id] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeContinuation(id) }
            }
        }
    }

    private func receiveLoop() async {
        guard let task else { return }
        do {
            while true {
                let message = try await task.receive()
                try handle(message: message)
            }
        } catch {
            broadcast(.disconnected)
        }
    }

    private func send(payload: SocketPayload) async throws {
        let data = try encoder.encode(payload)
        guard let text = String(data: data, encoding: .utf8) else { return }
        try await task?.send(.string(text))
    }

    private func handle(message: URLSessionWebSocketTask.Message) throws {
        let data: Data
        switch message {
        case .data(let value):
            data = value
        case .string(let value):
            data = Data(value.utf8)
        @unknown default:
            return
        }
        let payload = try decoder.decode(SocketPayload.self, from: data)
        switch payload.type {
        case "message":
            if let message = payload.message { broadcast(.messageReceived(message)) }
        case "typing":
            if let conversationId = payload.conversationId, let userId = payload.userId, let isTyping = payload.isTyping {
                broadcast(.typing(conversationId: conversationId, userId: userId, isTyping: isTyping))
            }
        case "presence":
            if let userId = payload.userId, let isOnline = payload.isOnline {
                broadcast(.presence(userId: userId, isOnline: isOnline))
            }
        default:
            break
        }
    }

    private func broadcast(_ event: SocketEvent) {
        continuations.values.forEach { $0.yield(event) }
    }

    private func removeContinuation(_ id: UUID) {
        continuations[id] = nil
    }

    private func disconnectCurrentTask() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
    }
}

private struct SocketPayload: Codable {
    let type: String
    let message: Message?
    let conversationId: String?
    let userId: String?
    let isTyping: Bool?
    let isOnline: Bool?
}
