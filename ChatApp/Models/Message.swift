import Foundation

enum MessageStatus: String, Codable, Sendable {
    case sending
    case sent
    case delivered
    case read
    case failed
}

struct Message: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let senderId: String
    let receiverId: String
    var text: String?
    var imageURL: URL?
    var createdAt: Date
    var status: MessageStatus
}
