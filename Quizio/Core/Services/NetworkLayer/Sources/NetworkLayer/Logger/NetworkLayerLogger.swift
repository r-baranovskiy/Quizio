import OSLog

public protocol INetworkLayerLogger: AnyObject
{
    func logCurl(from request: URLRequest)
}

public final class NetworkLayerLogger
{
  private let logger: Logger

  public init(logger: Logger = .init(subsystem: "com.koko6a.Quizio", category: "cURL")) {
    self.logger = logger
  }
}

extension NetworkLayerLogger: INetworkLayerLogger
{
    public func logCurl(from request: URLRequest) {
  #if DEBUG
      var curlComponents: [String] = ["curl --location"]

      guard let url = request.url else {
        print("⚠️ Invalid URL")
        return
      }
      curlComponents.append("'\(url.absoluteString)'")

      if let method = request.httpMethod {
        curlComponents.append("-X \(method)")
      }

      if let headers = request.allHTTPHeaderFields {
        for (header, value) in headers {
          curlComponents.append("--header '\(header): \(value)'")
        }
      }

      if let bodyData = request.httpBody,
         let bodyString = String(data: bodyData, encoding: .utf8),
         !bodyString.isEmpty {
        curlComponents.append("--data '\(bodyString)'")
      }

      let curlCommand = curlComponents.joined(separator: " \\\n")

      logger.info(
        """
        ========================
        🥷 Generated cURL:
        ========================
        \(curlCommand)
        ========================
        """
      )
  #endif
    }
}
