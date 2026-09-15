import XCTest
@testable import Quizio

final class ConfigRepositoryTests: XCTestCase
{
    /**
     Тест проверяет, что при вызове метода `getBaseUrl` вернется ожидаемое значение
     */
    func test_getConfig_shouldReturnExpectedValue() {
        // Given
        let env = Environment()
        let sut = env.makeSut()
        var result: String?

        env.configProvider.config = ["BASE_URL": "test"]

        // When
        result = try? sut.getBaseUrl()

        // Then
        XCTAssertEqual(result, "test")
    }
}

private extension ConfigRepositoryTests
{
    final class Environment
    {
        let configProvider = ConfigProviderMock()

        func makeSut() -> ConfigRepository {
            ConfigRepository(configProvider: configProvider)
        }
    }
}
