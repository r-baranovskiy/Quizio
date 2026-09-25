import Foundation

protocol IGetBaseUrlUseCase
{
    func getBaseUrl() throws -> URL
}

final class GetBaseUrlUseCase
{
    private let configRepository: IConfigRepository

    init(configRepository: IConfigRepository) {
        self.configRepository = configRepository
    }
}

extension GetBaseUrlUseCase: IGetBaseUrlUseCase
{
    func getBaseUrl() throws -> URL {
        do {
            let base = try configRepository.getBaseUrl()
            guard let baseUrl = URL(string: base) else {
                throw NSError(domain: "error", code: 1)
            }
            return baseUrl
        } catch {
            throw error
        }
    }
}
