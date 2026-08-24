import Foundation

struct User: Identifiable, Codable, Hashable, Sendable {
    let id: String
    var name: String
    var email: String
    var profileImageURL: URL?
    var isOnline: Bool
}

struct AuthSession: Codable, Sendable {
    let token: String
    let user: User
}
