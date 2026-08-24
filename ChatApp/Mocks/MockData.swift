import Foundation

enum MockData {
    static let currentUser = User(id: "current-user", name: "Akshay Patil", email: "akshay@example.com", profileImageURL: nil, isOnline: true)
    static let maya = User(id: "user-2", name: "Maya Rao", email: "maya@example.com", profileImageURL: nil, isOnline: true)
    static let arjun = User(id: "user-3", name: "Arjun Mehta", email: "arjun@example.com", profileImageURL: nil, isOnline: false)

    static let messages: [String: [Message]] = [
        "conversation-1": [
            Message(id: "message-1", senderId: "current-user", receiverId: "user-2", text: "The latest TestFlight build is ready.", imageURL: nil, createdAt: Date().addingTimeInterval(-7200), status: .read),
            Message(id: "message-2", senderId: "user-2", receiverId: "current-user", text: "Can you review the latest build?", imageURL: nil, createdAt: Date().addingTimeInterval(-3600), status: .delivered)
        ],
        "conversation-2": [
            Message(id: "message-3", senderId: "user-3", receiverId: "current-user", text: "I added notes to the release checklist.", imageURL: nil, createdAt: Date().addingTimeInterval(-10800), status: .read)
        ]
    ]

    static var conversations: [Conversation] {
        [
            Conversation(id: "conversation-1", participants: [maya], lastMessage: messages["conversation-1"]?.last, unreadCount: 2),
            Conversation(id: "conversation-2", participants: [arjun], lastMessage: messages["conversation-2"]?.last, unreadCount: 0)
        ]
    }
}
