import XCTest
@testable import ChatApp

@MainActor
final class ChatServiceTests: XCTestCase {
    func testMockChatServiceReturnsConversations() async throws {
        let service = MockChatService()
        let conversations = try await service.conversations()

        XCTAssertEqual(conversations.count, 2)
        XCTAssertEqual(conversations.first?.participants.first?.name, "Maya Rao")
    }

    func testRepositoryCachesMessages() async throws {
        let service = MockChatService()
        let store = CoreDataLocalStore(inMemory: true)
        let repository = ChatRepository(service: service, localStore: store)

        let messages = try await repository.loadMessages(conversationId: "conversation-1", before: nil)
        let cached = try await store.cachedMessages(conversationId: "conversation-1")

        XCTAssertEqual(messages.count, cached.count)
    }
}
