import Foundation
import UserNotifications

protocol NotificationManaging: Sendable {
    func requestAuthorization() async throws -> Bool
    func scheduleNewMessageNotification(message: Message, senderName: String) async throws
    func deepLink(from response: UNNotificationResponse) -> AppDeepLink?
}

enum AppDeepLink: Hashable, Sendable {
    case chat(conversationId: String)
}

final class NotificationManager: NSObject, NotificationManaging, UNUserNotificationCenterDelegate {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
        super.init()
        center.delegate = self
    }

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleNewMessageNotification(message: Message, senderName: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = senderName
        content.body = message.text ?? "Sent an image"
        content.sound = .default
        content.userInfo = ["conversationId": message.senderId == "current-user" ? message.receiverId : message.senderId]

        let request = UNNotificationRequest(identifier: message.id, content: content, trigger: nil)
        try await center.add(request)
    }

    func deepLink(from response: UNNotificationResponse) -> AppDeepLink? {
        guard let conversationId = response.notification.request.content.userInfo["conversationId"] as? String else { return nil }
        return .chat(conversationId: conversationId)
    }
}
