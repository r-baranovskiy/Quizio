import Foundation

@testable import Quizio

final class ConfigRepositoryMock: IConfigRepository
{
    var baseUrl: String = ""
    var error: Error?

    private(set) var getBaseUrlCallCount = 0

    func getBaseUrl() throws -> String {
        getBaseUrlCallCount += 1

        if let error {
            throw error
        }

        return baseUrl
    }
}
