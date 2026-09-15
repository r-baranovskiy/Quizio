import Foundation

protocol IConfigProvider: AnyObject
{
    func obtainConfig(for key: String) throws -> String
}

final class ConfigProvider
{
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }
}

extension ConfigProvider: IConfigProvider
{
    func obtainConfig(for key: String) throws -> String {
        guard let property = bundle.object(
            forInfoDictionaryKey: key
        ) as? String else {
            throw NSError(domain: "Error \(key) property undefined", code: 1)
        }
        return property
    }
}
