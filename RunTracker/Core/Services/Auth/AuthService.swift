//
//  AuthService.swift
//  RunTracker
//
//  Created by Michael Callahan on 10/23/26.
//

import SwiftUI
import OpenAPIRuntime

struct AuthService {
    private let client: Client
    private let tokenStore: AuthTokenStore
    
    init(
        client: Client
    ) {
        self.client = client
        self.tokenStore = AuthTokenStore()
    }
    
    func loginRequest(code: String) async throws {
        let body = Components.Schemas.ExchangeCodeRequest(code: code)
        let response = try await client.login(body: .json(body))
        let tokenResponse = try AuthToken(response.ok.body.json)
        
        await tokenStore.set(tokenResponse.accessToken)
    }
    
    func handleLogin(url: URL) async throws {
        let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first { $0.name == "code" }?.value
        
        if let code {
            try await self.loginRequest(code: code)
        }
    }
}
