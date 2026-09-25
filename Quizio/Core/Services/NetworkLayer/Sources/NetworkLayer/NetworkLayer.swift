import Foundation

public protocol INetworkLayer: AnyObject
{
    /// Выполняет сетевой запрос и возвращает типизированный результат.
    ///
    /// Метод отправляет HTTP-запрос и маппит ответ в `NetworkClientResponse`:
    /// - 1xx → `.informationResponse(code:)`
    /// - 2xx → `.successResponse(code:data:)` с телом ответа
    /// - 3xx → `.redirectionMessage(code:)`
    /// - прочие коды → `.error(.codeError(...))` внутри возвращаемого значения.
    ///   Ошибка по статус-коду здесь не бросается — она вылетит при вызове
    ///   `NetworkClientResponse.prepareData`
    ///
    /// - Parameters:
    ///   - request: `URLRequest` с настроенными заголовками, методом и телом запроса
    ///   - logger: Опциональный логгер. Если передан, запрос будет залогирован
    ///             в формате cURL до отправки через `logger.logCurl(from:)`
    ///
    /// - Returns: `NetworkClientResponse`, описывающий результат по статус-коду
    ///
    /// - Throws: `NetworkClientError`:
    ///   - `.badResponse` — если ответ сервера не является HTTP-ответом
    ///   - `.transportError(TransportError)` — при сетевых ошибках:
    ///     - `.offline` — нет подключения к интернету
    ///     - `.timeout` — таймаут запроса
    ///     - `.tlsFailure` — ошибка SSL/TLS сертификата
    ///     - `.dnsFailure` — не удалось разрешить DNS-имя
    ///     - `.cannotConnect` — не удалось подключиться к хосту
    ///     - `.cancelled` — запрос был отменен
    ///     - `.unknown` — неизвестная сетевая ошибка
    func request(for request: URLRequest,
                 with logger: INetworkLayerLogger?) async throws -> NetworkClientResponse
}

public final class NetworkLayer
{
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }
}

extension NetworkLayer: INetworkLayer
{
    public func request(for request: URLRequest,
                        with logger: INetworkLayerLogger?) async throws -> NetworkClientResponse {
        if let logger {
            logger.logCurl(from: request)
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                throw NetworkClientError.badResponse
            }
            let clientResponse = NetworkClientResponse(urlResponse: response, data: data)

            return clientResponse
        } catch let error as URLError {
            throw self.prepareUrlError(from: error)
        }
    }
}

// MARK: - Private
private extension NetworkLayer {
    func prepareUrlError(
        from error: URLError
    ) -> NetworkClientError {
        let transportError: TransportError = switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                .offline
        case .secureConnectionFailed, .serverCertificateHasBadDate, .serverCertificateUntrusted, .serverCertificateHasUnknownRoot:
                .tlsFailure
        case .timedOut:
                .timeout
        case .dnsLookupFailed, .cannotFindHost:
                .dnsFailure
        case .cannotConnectToHost:
                .cannotConnect
        case .cancelled:
                .cancelled
        default:
                .unknown
        }

        return .transportError(error: transportError)
    }
}
