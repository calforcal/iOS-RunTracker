import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

enum APIClient {
    static let shared: Client = {
        guard let serverURL = try? Servers.Server1.url() else {
            fatalError("Invalid server URL in openapi.yaml")
        }
        return Client(
            serverURL: serverURL,
            transport: URLSessionTransport(),
            middlewares: [AuthenticationMiddleware(tokenStore: .shared)]
        )
    }()
}
