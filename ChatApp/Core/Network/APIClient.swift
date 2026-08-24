import Foundation

protocol APIClientProtocol: Sendable {
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T
}

final class APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: URL = URL(string: "https://api.chatapp.local")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }

    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        guard var components = URLComponents(url: baseURL.appending(path: endpoint.path), resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems
        guard let url = components.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        endpoint.headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        if let body = endpoint.body {
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
            switch httpResponse.statusCode {
            case 200...299:
                do { return try decoder.decode(T.self, from: data) } catch { throw NetworkError.decodingFailed }
            case 401:
                throw NetworkError.unauthorized
            default:
                throw NetworkError.serverError(httpResponse.statusCode)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }
    }
}

private struct AnyEncodable: Encodable {
    private let encodeValue: (Encoder) throws -> Void

    init(_ value: Encodable) {
        self.encodeValue = value.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeValue(encoder)
    }
}
