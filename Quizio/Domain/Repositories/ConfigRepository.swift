import Foundation

protocol IConfigRepository
{
    func getBaseUrl() throws -> String
}

final class ConfigRepository
{
    private enum Constants
    {
        static let baseUrlKey = "BASE_URL"
    }

    private let configProvider: IConfigProvider

    init(configProvider: IConfigProvider) {
        self.configProvider = configProvider
    }
}

extension ConfigRepository: IConfigRepository
{
    func getBaseUrl() throws -> String {
        try self.configProvider.obtainConfig(for: Constants.baseUrlKey)
    }
}
