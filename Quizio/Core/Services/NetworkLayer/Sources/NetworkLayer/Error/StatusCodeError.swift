import Foundation

public enum StatusCodeError: Error, Equatable
{
    case clientError(code: Int)
    case serverError(code: Int)
    case unknown(code: Int)

    public init(statusCode: Int) {
        switch statusCode {
        case 400...499: self = .clientError(code: statusCode)
        case 500...599: self = .serverError(code: statusCode)
        default: self = .unknown(code: statusCode)
        }
    }
}
