import Foundation
import NetworkLayer

final class NetworkLayerMock: INetworkLayer
{
    var result: NetworkClientResponse = .successResponse(code: 200, data: Data())
    var error: Error?

    private(set) var requestCallCount = 0
    private(set) var receivedRequest: URLRequest?

    func request(for request: URLRequest,
                 with logger: INetworkLayerLogger?) async throws -> NetworkClientResponse {
        requestCallCount += 1
        receivedRequest = request

        if let error {
            throw error
        }

        return result
    }
}
