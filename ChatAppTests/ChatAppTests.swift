import XCTest
@testable import ChatApp

final class ChatAppTests: XCTestCase {
    func testMockDataHasValidConversation() {
        XCTAssertEqual(MockData.conversations.first?.id, "conversation-1")
        XCTAssertNotNil(MockData.conversations.first?.lastMessage)
    }
}
