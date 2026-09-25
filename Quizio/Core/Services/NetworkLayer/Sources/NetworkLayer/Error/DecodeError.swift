import Foundation

public enum DecodeError: Error
{
    case typeMismatch(description: String)
    case valueNotFound(description: String)
    case keyNotFound(description: String)
    case `default`(description: String)
    
    static func makeError<T: Decodable>(for type: T.Type, and error: DecodingError) -> DecodeError {
        switch error {
        case .typeMismatch(let any, let context):
                .typeMismatch(
                    description: "Type mismatch for type \(any) in \(T.self) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
        case .valueNotFound(let any, let context):
                .valueNotFound(
                    description: "Value not found for type \(any) in \(T.self) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                )
        case .keyNotFound(let codingKey, let context):
                .keyNotFound(
                    description: "Missing key '\(codingKey.stringValue)' in \(T.self) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                )
        default:
                .`default`(
                    description: "Failed to decode \(T.self): \(error.localizedDescription)"
                )
        }
    }
}

extension DecodeError: Equatable
{
    public static func == (lhs: DecodeError, rhs: DecodeError) -> Bool {
        switch (lhs, rhs) {
        case (.typeMismatch, .typeMismatch):
            return true
        case (.valueNotFound, .valueNotFound):
            return true
        case (.keyNotFound, .keyNotFound):
            return true
        case (.`default`, .`default`):
            return true
        default: return false
        }
    }
}
