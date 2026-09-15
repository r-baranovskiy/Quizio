import Foundation

@testable import Quizio

final class ConfigProviderMock: IConfigProvider
{
    var config: [String: String] = [:]
    var error: Error?

    private(set) var obtainConfigCount = 0

    func obtainConfig(for key: String) throws -> String {
        obtainConfigCount += 1

        if let error {
            throw error
        }

        guard let value = config[key] else {
            throw NSError(domain: "ConfigProviderMock: value for key \(key) is undefined", code: 1)
        }

        return value
    }
}
