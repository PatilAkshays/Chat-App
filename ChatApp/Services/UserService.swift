import Foundation

protocol UserServiceProtocol: Sendable {
    func searchUsers(query: String) async throws -> [User]
    func profile(userId: String) async throws -> User
}

final class UserService: UserServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func searchUsers(query: String) async throws -> [User] {
        try await apiClient.request(endpoint: Endpoint(path: "/users/search", queryItems: [URLQueryItem(name: "q", value: query)]))
    }

    func profile(userId: String) async throws -> User {
        try await apiClient.request(endpoint: Endpoint(path: "/users/\(userId)"))
    }
}
