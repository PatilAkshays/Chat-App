import XCTest
@testable import ChatApp

@MainActor
final class LoginViewModelTests: XCTestCase {
    func testLoginWithValidCredentialsAuthenticates() async {
        let service = MockAuthService()
        let repository = AuthRepository(service: service)
        let expectation = expectation(description: "Authenticated")
        var authenticatedSession: AuthSession?
        let viewModel = LoginViewModel(repository: repository) { session in
            authenticatedSession = session
            expectation.fulfill()
        }

        viewModel.email = "akshay@example.com"
        viewModel.password = "password123"
        viewModel.login()

        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(authenticatedSession?.user.id, "current-user")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoginWithInvalidEmailShowsValidationError() async {
        let repository = AuthRepository(service: MockAuthService())
        let viewModel = LoginViewModel(repository: repository) { _ in XCTFail("Should not authenticate") }

        viewModel.email = "invalid"
        viewModel.password = "password123"
        viewModel.login()

        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(viewModel.errorMessage, AuthError.invalidEmail.localizedDescription)
    }
}
