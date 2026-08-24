import Combine
import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: User?
    @Published var errorMessage: String?

    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func load() {
        Task {
            do {
                user = try await repository.currentSession()?.user
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
