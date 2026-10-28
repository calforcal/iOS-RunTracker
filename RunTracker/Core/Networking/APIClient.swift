import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

enum APIClient {
    static let shared: Client = {
        let serverURL = URL(string: "https://run-tracker-api-saqxt.ondigitalocean.app")!
        return Client(
            serverURL: serverURL,
            transport: URLSessionTransport(),
            middlewares: [AuthenticationMiddleware(tokenStore: .shared)]
        )
    }()
}
