import XCTest
@testable import NetworkLayer

final class RequestBuilderTests: XCTestCase
{
    /**
     Тест проверяет, что реквест корректно создается с HTTP методом `GET`
    */
    func test_makeRequest_withHttpMethodGET_correctCreated() {
        // Given
        let env = Environment()
        let sut = env.makeSut(TestFactory.baseURL())
        let expectedRequest = TestFactory.makeRequest(url: TestFactory.baseURL(),
                                                      HTTPMethod: "GET")
        var request: URLRequest?

        // When
        do {
            request = try sut
                .httpMethod(.get)
                .build()
        } catch {
            XCTFail(error.localizedDescription)
        }

        // Then
        XCTAssertEqual(expectedRequest, request)
    }

    /**
     Тест проверяет, что реквест корректно создается с HTTP методом `POST`
    */
    func test_makeRequest_withHttpMethodPOST_correctCreated() {
        // Given
        let env = Environment()

        let sut = env.makeSut(TestFactory.baseURL())
        let expectedRequest = TestFactory.makeRequest(url: TestFactory.baseURL(),
                                                      HTTPMethod: "POST")
        var request: URLRequest?

        // When
        do {
            request = try sut
                .httpMethod(.post)
                .build()
        } catch {
            XCTFail(error.localizedDescription)
        }

        // Then
        XCTAssertEqual(expectedRequest, request)
    }

    /**
     Тест проверяет, что реквест корректно создается если к URL добавить `path`
    */
    func test_makeRequest_withPath_correctCreated() {
        // Given
        let env = Environment()
        let expectedURL = TestFactory.baseURL("/pictures")
        let sut = env.makeSut(TestFactory.baseURL())
        let expectedRequest = TestFactory.makeRequest(url: expectedURL, HTTPMethod: "GET")
        var request: URLRequest?

        // When
        do {
            request = try sut
                .path("pictures")
                .build()
        } catch {
            XCTFail(error.localizedDescription)
        }

        // Then
        XCTAssertEqual(expectedRequest, request)
    }

    /**
     Тест проверяет, что реквест корректно создается если добавить `Headers`
    */
    func test_makeRequest_withHeaders_correctCreated() {
        // Given
        let env = Environment()
        let sut = env.makeSut(TestFactory.baseURL())
        let expectedHeaders = ["API_Key": "123456",
                               "Content-Type": "application/json"]
        let expectedRequest = TestFactory.makeRequest(url: TestFactory.baseURL(),
                                                      HTTPMethod: "GET",
                                                      headers: expectedHeaders)
        var request: URLRequest?

        // When
        do {
            request = try sut
                .addHeader("API_Key", value: "123456")
                .addHeader("Content-Type", value: "application/json")
                .build()
        } catch {
            XCTFail(error.localizedDescription)
        }

        // Then
        XCTAssertEqual(expectedRequest, request)
    }

    /**
     Тест проверяет, что реквест корректно создается если добавить `Content-Type`
    */
    func test_makeRequest_withContentType_correctCreated() {
        // Given
        let env = Environment()
        let sut = env.makeSut(TestFactory.baseURL())
        let expectedHeaders = ["Content-Type": "multipart/form-data"]
        let expectedRequest = TestFactory.makeRequest(url: TestFactory.baseURL(),
                                                      HTTPMethod: "POST",
                                                      headers: expectedHeaders)
        var request: URLRequest?

        // When
        do {
            request = try sut
                .contentType(.multipart)
                .httpMethod(.post)
                .build()
        } catch {
            XCTFail(error.localizedDescription)
        }

        // Then
        XCTAssertEqual(expectedRequest, request)
    }

    /**
     Тест проверяет, что реквест корректно создается если добавить `Authorization`
    */
    func test_makeRequest_withAuthorization_correctCreated() {
        // Given
        let env = Environment()
        let sut = env.makeSut(TestFactory.baseURL())
        let expectedHeaders = ["Authorization": "Bearer 123456"]
        let expectedRequest = TestFactory.makeRequest(url: TestFactory.baseURL(),
                                                      HTTPMethod: "GET",
                                                      headers: expectedHeaders)
        var request: URLRequest?

        // When
        do {
            request = try sut
                .authorizationBearer("123456")
                .build()
        } catch {
            XCTFail(error.localizedDescription)
        }

        // Then
        XCTAssertEqual(expectedRequest, request)
    }

    /**
     Тест проверяет, что реквест корректно создается если добавить `Body`
    */
    func test_makeRequest_withBody_correctCreated() {
        // Given
        let env = Environment()
        let sut = env.makeSut(TestFactory.baseURL())
        let data = Data()
        let expectedRequest = TestFactory.makeRequest(url: TestFactory.baseURL(),
                                                      HTTPMethod: "POST",
                                                      body: data)
        var request: URLRequest?

        // When
        do {
            request = try sut
                .body(data)
                .httpMethod(.post)
                .build()
        } catch {
            XCTFail(error.localizedDescription)
        }

        // Then
        XCTAssertEqual(expectedRequest, request)
    }

    /**
     Тест проверяет, что реквест корректно создается если добавить `Query`.
     Порядок параметров из словаря недетерминирован, поэтому сравнение идет через множество
     */
    func test_makeRequest_withQuery_correctCreated() {
        // Given
        let env = Environment()
        let sut = env.makeSut(TestFactory.baseURL())
        let expectedQueryItems = Set([URLQueryItem(name: "a", value: "1"),
                                      URLQueryItem(name: "b", value: "2")])
        var request: URLRequest?

        // When
        do {
            request = try sut
                .query(["a": "1", "b": "2"])
                .build()
        } catch {
            XCTFail(error.localizedDescription)
        }

        // Then
        guard let url = request?.url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            XCTFail("URL is undefined")
            return
        }

        XCTAssertEqual(components.host, "google.com")
        XCTAssertEqual(Set(components.queryItems ?? []), expectedQueryItems)
    }

    /**
     Тест проверяет, что при невалидном `baseURL` выбрасывается ошибка `NetworkClientError.invalidURL`
     */
    func test_makeRequest_withInvalidBaseURL_throwsInvalidURL() {
        // Given
        let env = Environment()
        let sut = env.makeSut("https://exa mple.com")
        var resultError: NetworkClientError?

        // When
        do {
            _ = try sut.build()
        } catch let error as NetworkClientError {
            resultError = error
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        // Then
        XCTAssertEqual(resultError, .invalidURL)
    }
}

private extension RequestBuilderTests
{
    final class Environment
    {
        func makeSut(_ url: URL) -> IRequestBuilder {
            RequestBuilder(baseURL: url.absoluteString)
        }

        func makeSut(_ baseURL: String) -> IRequestBuilder {
            RequestBuilder(baseURL: baseURL)
        }
    }
}

private extension RequestBuilderTests
{
    enum TestFactory
    {
        static func baseURL(_ path: String = "") -> URL {
            let baseURL: URL = URL(string: "https://google.com")!
                .appending(path: path)
            return baseURL
        }

        static func makeRequest(url: URL,
                                HTTPMethod: String,
                                headers: [String: String] = [:],
                                body: Data? = nil) -> URLRequest {
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod
            request.allHTTPHeaderFields = headers
            request.httpBody = body
            return request
        }
    }
}
