import Foundation

struct RequestConfig
{
    var path: String?
    var body: Data?
    var headers: [String: String] = [:]
    var queryItems: [URLQueryItem] = []
    var method: HTTPMethod = .get
}
