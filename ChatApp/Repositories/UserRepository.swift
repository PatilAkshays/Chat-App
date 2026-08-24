import Foundation

protocol UserRepositoryProtocol: Sendable {
    func searchUsers(query: String) async throws -> [User]
    func profile(userId: String) async throws -> User
}

final class UserRepository: UserRepositoryProtocol {
    private let service: UserServiceProtocol
    private let localStore: LocalStoreProtocol

    init(service: UserServiceProtocol, localStore: LocalStoreProtocol) {
        self.service = service
        self.localStore = localStore
    }

    func searchUsers(query: String) async throws -> [User] {
        let users = try await service.searchUsers(query: query)
        try await localStore.cache(users: users)
        return users
    }

    func profile(userId: String) async throws -> User {
        let user = try await service.profile(userId: userId)
        try await localStore.cache(users: [user])
        return user
    }
}
