import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(Int)
    case decodingFailed
    case noInternet
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .unauthorized:
            return "Your session has expired. Please sign in again."
        case .serverError(let code):
            return "Server error (\(code)). Please try again."
        case .decodingFailed:
            return "Unable to read server response."
        case .noInternet:
            return "No internet connection. Showing cached data when available."
        case .unknown(let message):
            return message
        }
    }
}
