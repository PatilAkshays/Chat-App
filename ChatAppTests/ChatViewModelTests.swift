import XCTest
@testable import ChatApp

@MainActor
final class ChatViewModelTests: XCTestCase {
    func testLoadMessagesUsesRepository() async {
        let service = MockChatService()
        let store = CoreDataLocalStore(inMemory: true)
        let repository = ChatRepository(service: service, localStore: store)
        let conversation = MockData.conversations[0]
        let viewModel = ChatViewModel(conversation: conversation, service: service, repository: repository)

        viewModel.load()
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertFalse(viewModel.messages.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSendAppendsMessage() async {
        let service = MockChatService()
        let store = CoreDataLocalStore(inMemory: true)
        let repository = ChatRepository(service: service, localStore: store)
        let conversation = MockData.conversations[0]
        let viewModel = ChatViewModel(conversation: conversation, service: service, repository: repository)

        viewModel.inputText = "Hello"
        viewModel.send()
        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(viewModel.messages.contains { $0.text == "Hello" })
    }
}
