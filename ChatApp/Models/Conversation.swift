import Foundation

struct Conversation: Identifiable, Codable, Hashable, Sendable {
    let id: String
    var participants: [User]
    var lastMessage: Message?
    var unreadCount: Int

    var displayUser: User? {
        participants.first
    }
}
