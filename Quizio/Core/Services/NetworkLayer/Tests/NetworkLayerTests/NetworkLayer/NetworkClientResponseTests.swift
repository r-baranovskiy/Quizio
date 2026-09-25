import XCTest
@testable import NetworkLayer

final class NetworkClientResponseTests: XCTestCase
{
    /**
     Тест проверяет, что инициализатор корректно маппит статус-коды ответа в кейсы enum'а
     */
    func test_init_withStatusCodes_correctMapping() {
        // Given
        let env = Environment()
        let cases: [(code: Int, expected: NetworkClientResponse)] = [
            (100, .informationResponse(code: 100)),
            (150, .informationResponse(code: 150)),
            (200, .successResponse(code: 200, data: env.testData)),
            (204, .successResponse(code: 204, data: env.testData)),
            (301, .redirectionMessage(code: 301)),
            (404, .error(.codeError(error: .clientError(code: 404)))),
            (500, .error(.codeError(error: .serverError(code: 500))))
        ]

        for testCase in cases {
            // When
            let response = env.makeSut(statusCode: testCase.code)

            // Then
            XCTAssertEqual(response, testCase.expected)
        }
    }

    /**
     Тест проверяет, что prepareData декодирует модель из данных успешного ответа
     */
    func test_prepareData_withSuccessResponse_returnsDecodedModel() throws {
        // Given
        let env = Environment()
        let sut = NetworkClientResponse.successResponse(code: 200, data: env.encodedMock)

        // When
        let result: MockResponse = try sut.prepareData()

        // Then
        XCTAssertEqual(result, TestFactory.mockModel)
    }

    /**
     Тест проверяет, что prepareData пробрасывает ошибку из кейса .error без изменений
     */
    func test_prepareData_withErrorCase_throwsSameError() {
        // Given
        let expectedError = NetworkClientError.codeError(error: .clientError(code: 418))
        let sut = NetworkClientResponse.error(expectedError)
        var resultError: NetworkClientError?

        // When
        do {
            let _: MockResponse = try sut.prepareData()
        } catch let error as NetworkClientError {
            resultError = error
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        // Then
        XCTAssertEqual(resultError, expectedError)
    }

    /**
     Тест проверяет, что prepareData для 1xx и 3xx ответов выбрасывает decodingError
     */
    func test_prepareData_withInformationAndRedirection_throwsDecodingError() {
        // Given
        let responses = [NetworkClientResponse.informationResponse(code: 100),
                         NetworkClientResponse.redirectionMessage(code: 302)]

        for sut in responses {
            // When
            var resultError: NetworkClientError?
            do {
                let _: MockResponse = try sut.prepareData()
            } catch let error as NetworkClientError {
                resultError = error
            } catch {
                XCTFail("Unexpected error type: \(error)")
            }

            // Then
            guard case .decodingError = resultError else {
                XCTFail("Expected decodingError, got \(String(describing: resultError))")
                return
            }
        }
    }
}

private extension NetworkClientResponseTests
{
    final class Environment
    {
        let testData = Data()

        var encodedMock: Data {
            try! JSONEncoder().encode(TestFactory.mockModel)
        }

        func makeSut(statusCode: Int) -> NetworkClientResponse {
            let response = HTTPURLResponse(url: TestFactory.url,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return NetworkClientResponse(urlResponse: response, data: testData)
        }
    }

    enum TestFactory
    {
        static let url = URL(string: "https://test.com")!
        static let mockModel = MockResponse(id: 1, name: "test")
    }
}
