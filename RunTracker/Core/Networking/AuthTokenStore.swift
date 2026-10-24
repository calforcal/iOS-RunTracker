import Foundation

actor AuthTokenStore {
    static let shared = AuthTokenStore()

    private var token: String?

    func set(_ token: String?) {
        self.token = token
    }

    func current() -> String? {
        token
    }
}
