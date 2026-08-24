import Foundation

actor MockUserService: UserServiceProtocol {
    func searchUsers(query: String) async throws -> [User] {
        let users = [MockData.maya, MockData.arjun]
        guard !query.isEmpty else { return users }
        return users.filter { $0.name.localizedCaseInsensitiveContains(query) || $0.email.localizedCaseInsensitiveContains(query) }
    }

    func profile(userId: String) async throws -> User {
        ([MockData.currentUser, MockData.maya, MockData.arjun].first { $0.id == userId }) ?? MockData.currentUser
    }
}
