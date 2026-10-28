//
//  WebAuthenticator.swift
//  RunTracker
//
//  Created by Michael Callahan on 10/24/26.
//

import Foundation

protocol WebAuthenticator {
    func authenticate(using: URL, callbackURLScheme: String) async throws -> URL
}
