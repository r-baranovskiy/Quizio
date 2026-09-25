import XCTest
@testable import NetworkLayer

final class NetworkLayerTests: XCTestCase
{
    /// Тест проверяет, что если в ответе будет статус код 4хх
    /// то получим ошибку `StatusCodeError.clientError`
    func test_for4xxStatusCodes_requestThrowsClientError() async {
        // Given
        let env = Environment()
        let sut = env.makeSut()
        let receivedCodes = [400, 401, 403, 404, 429]

        // When
        for code in receivedCodes {
            let expectation = expectation(description: "Test code expectation \(code)")
            let expectedError = NetworkClientError.codeError(error: .clientError(code: code))
            var receivedError: NetworkClientError?

            MockURLProtocol.requestHandler = { request in
                let response = HTTPURLResponse(url: request.url!,
                                             statusCode: code,
                                             httpVersion: nil,
                                             headerFields: nil)!
                return (response, Data())
            }

            do {
                let _: MockResponse = try await sut
                    .request(for: TestFactory.urlRequest, with: nil)
                    .prepareData()
            } catch {
                receivedError = error as? NetworkClientError
                expectation.fulfill()
            }

            // Then
            await fulfillment(of: [expectation], timeout: 0.1)
            XCTAssertEqual(receivedError, expectedError)
        }
    }

     /// Тест проверяет, что если в ответе будет статус код 5хх
     /// то получим ошибку `StatusCodeError.serverError`
    func test_for5xxStatusCodes_requestThrowsServerError() async {
        // Given
        let env = Environment()
        let sut = env.makeSut()
        let receivedCodes = [502, 510, 530, 550, 599]

        // When
        for code in receivedCodes {
            let expectation = expectation(description: "Test code expectation \(code)")
            let expectedError = NetworkClientError.codeError(error: .serverError(code: code))
            var receivedError: NetworkClientError?

            MockURLProtocol.requestHandler = { request in
                let response = HTTPURLResponse(url: request.url!,
                                             statusCode: code,
                                             httpVersion: nil,
                                             headerFields: nil)!
                return (response, Data())
            }

            do {
                let _: MockResponse = try await sut
                    .request(for: TestFactory.urlRequest, with: nil)
                    .prepareData()
            } catch {
                receivedError = error as? NetworkClientError
                expectation.fulfill()
            }

            // Then
            await fulfillment(of: [expectation], timeout: 0.1)
            XCTAssertEqual(receivedError, expectedError)
        }
    }

    /// Тест проверяет, что для 200 статуса и корректных декодируемых свойств
    /// вернется ожидаемая модель данных`
    func test_for200StatusCode_requestSuccessDecodingData() async {
        // Given
        let env = Environment()
        let sut = env.makeSut()
        let expectation = expectation(description: #function)
        var receivedResponse: MockResponse?

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                         statusCode: 200,
                                         httpVersion: nil,
                                         headerFields: nil)!
            return (response, TestFactory.mockData()!)
        }

        // When
        do {
            receivedResponse = try await sut
                .request(for: TestFactory.urlRequest, with: nil)
                .prepareData()
            expectation.fulfill()
        } catch {
            XCTFail(error.localizedDescription)
        }

        // Then
        await fulfillment(of: [expectation], timeout: 0.1)
        XCTAssertEqual(TestFactory.mockModel, receivedResponse)
    }

    /*
     Тест проверяет, что для успешного статус кода вернется `DecodingError`
     если модель данных для декодирования будет некорректной
     */
    func test_for200StatusCodeAndInvalidData_requestThrowsDecodingError() async {
        // Given
        let env = Environment()
        let sut = env.makeSut()
        let expectation = expectation(description: #function)
        let expectedError = NetworkClientError.decodingError(error: .default(description: ""))
        var receivedError: NetworkClientError?

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                         statusCode: 200,
                                         httpVersion: nil,
                                         headerFields: nil)!
            return (response, Data())
        }

        // When
        do {
            let _: MockResponse? = try await sut
                .request(for: TestFactory.urlRequest, with: nil)
                .prepareData()
            XCTFail("Сюда попасть не должны")
        } catch {
            receivedError = error as? NetworkClientError
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation], timeout: 0.1)
        XCTAssertEqual(expectedError, receivedError)
    }

    /**
     Тест проверяет, что сетевая ошибка `URLError` маппится в `NetworkClientError.transportError`
     */
    func test_withUrlError_requestThrowsTransportError() async {
        // Given
        let env = Environment()
        let sut = env.makeSut()
        let expectation = expectation(description: #function)
        let expectedError = NetworkClientError.transportError(error: .offline)
        var receivedError: NetworkClientError?

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        // When
        do {
            let _: MockResponse = try await sut
                .request(for: TestFactory.urlRequest, with: nil)
                .prepareData()
            XCTFail("Сюда попасть не должны")
        } catch {
            receivedError = error as? NetworkClientError
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation], timeout: 0.1)
        XCTAssertEqual(expectedError, receivedError)
    }
}

private extension NetworkLayerTests
{
    final class Environment
    {
        func makeSut() -> NetworkLayer {
            let configuration = URLSessionConfiguration.default
            configuration.protocolClasses = [MockURLProtocol.self]
            let session = URLSession(configuration: configuration)
            return NetworkLayer(session: session)
        }
    }
}

private extension NetworkLayerTests
{
    enum TestFactory
    {
        static let urlRequest = URLRequest(url: URL(string: "https://test.com")!)
        static let mockModel = MockResponse(id: 1, name: "test")

        static func mockData(_ encoder: JSONEncoder = .init()) -> Data? {
            try? encoder.encode(mockModel)
        }
    }
}
