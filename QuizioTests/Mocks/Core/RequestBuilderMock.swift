import Foundation
import NetworkLayer

final class RequestBuilderMock: IRequestBuilder
{
    private(set) var buildCallCount = 0

    func build() throws -> URLRequest {
        buildCallCount += 1
        return URLRequest(url: URL(string: "https://test.com")!)
    }

    func httpMethod(_ method: HTTPMethod) -> Self { self }
    func addHeader(_ key: String, value: String) -> Self { self }
    func query(_ items: [String: String]) -> Self { self }
    func path(_ path: String) -> Self { self }
    func contentType(_ type: ContentType) -> Self { self }
    func authorizationBearer(_ token: String) -> Self { self }
    func body(_ data: Data) -> Self { self }
}
