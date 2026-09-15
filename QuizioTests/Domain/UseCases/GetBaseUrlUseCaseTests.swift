import XCTest
@testable import Quizio

final class GetBaseUrlUseCaseTests: XCTestCase
{
    /**
     Тест проверяет, что при вызове метода `getBaseUrl` происходит обращение к методу `getBaseUrl` репозитория
     */
    func test_getBaseUrl_shouldCallRepositoryGetBaseUrl() {
        // Given
        let env = Environment()
        let sut = env.makeSut()

        env.configRepository.baseUrl = "https://test.com"

        // When
        _ = try? sut.getBaseUrl()

        // Then
        XCTAssertEqual(env.configRepository.getBaseUrlCallCount, 1)
    }

    /**
     Тест проверяет, что при вызове метода `getBaseUrl` вернется ожидаемое значение
     */
    func test_getBaseUrl_shouldReturnExpectedValue() {
        // Given
        let env = Environment()
        let sut = env.makeSut()
        var result: URL?

        env.configRepository.baseUrl = "https://test.com"

        // When
        result = try? sut.getBaseUrl()

        // Then
        XCTAssertEqual(result, URL(string: "https://test.com"))
    }
}

private extension GetBaseUrlUseCaseTests
{
    final class Environment
    {
        let configRepository = ConfigRepositoryMock()

        func makeSut() -> GetBaseUrlUseCase {
            GetBaseUrlUseCase(configRepository: configRepository)
        }
    }
}
