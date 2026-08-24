import Foundation

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct Endpoint: Sendable {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let body: Encodable?
    let headers: [String: String]

    init(path: String, method: HTTPMethod = .get, queryItems: [URLQueryItem] = [], body: Encodable? = nil, headers: [String: String] = [:]) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = body
        self.headers = headers
    }
}
