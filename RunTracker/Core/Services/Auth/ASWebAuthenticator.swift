//
//  ASWebAuthenticator.swift
//  RunTracker
//
//  Created by Michael Callahan on 10/24/26.
//

import Foundation
import AuthenticationServices
import UIKit

final class ASWebAuthenticator: NSObject, WebAuthenticator {
    private var session: ASWebAuthenticationSession?

    func authenticate(using url: URL, callbackURLScheme: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: callbackURLScheme
            ) { callbackURL, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let callbackURL {
                    continuation.resume(returning: callbackURL)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
            session.presentationContextProvider = self
            self.session = session
            session.start()
        }
    }
}

extension ASWebAuthenticator: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }

        if let window = scenes.flatMap(\.windows).first(where: \.isKeyWindow) {
            return window
        }
        return ASPresentationAnchor(windowScene: scenes.first!)
    }
}
