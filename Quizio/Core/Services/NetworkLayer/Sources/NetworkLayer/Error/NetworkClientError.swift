import Foundation

public enum NetworkClientError: Error
{
    case invalidURL
    case badResponse
    case transportError(error: TransportError)
    case codeError(error: StatusCodeError)
    case decodingError(error: DecodeError)
}

extension NetworkClientError: LocalizedError
{
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .badResponse: return "Bad response"
        case .transportError(error: let error): return "Transport error: \(error)"
        case .codeError(error: let error): return "Code error: \(error)"
        case .decodingError(error: let error): return "Decoding error \(error)"
        }
    }
}

extension NetworkClientError: Equatable
{
    public static func == (lhs: NetworkClientError, rhs: NetworkClientError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.badResponse, .badResponse):
            return true
        case let (.transportError(lhsError), .transportError(rhsError)):
            return lhsError == rhsError
        case let (.codeError(lhsError), .codeError(rhsError)):
            return lhsError == rhsError
        case let (.decodingError(lhsError), .decodingError(rhsError)):
            return lhsError == rhsError
        default: return false
        }
    }
}
