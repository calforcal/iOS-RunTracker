//
//  AuthService.swift
//  RunTracker
//
//  Created by Michael Callahan on 10/23/26.
//

import SwiftUI
import OpenAPIRuntime
import AuthenticationServices

struct AuthService {
    private let client: Client
    private let tokenStore: AuthTokenStore
    private let webSession: WebAuthenticator
    
    init(
        client: Client,
        webSession: WebAuthenticator
    ) {
        self.client = client
        self.webSession = webSession
        self.tokenStore = AuthTokenStore()
    }
    
    private static let callbackScheme = Environment.appCallbackScheme
    private static let stravaRedirectURI = "\(Environment.appCallbackScheme)://\(Environment.appCallbackHost)"
    
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
    
    private func stravaAuthURL(base: String) -> URL {
        func encode(_ value: String) -> String {
            value.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? value
        }

        var components = URLComponents(string: base)!
        components.percentEncodedQueryItems = [
            .init(name: "client_id", value: Environment.stravaClientID),
            .init(name: "redirect_uri", value: encode(Self.stravaRedirectURI)),
            .init(name: "response_type", value: "code"),
            .init(name: "approval_prompt", value: "auto"),
            .init(name: "scope", value: encode("read,activity:read_all")),
            .init(name: "state", value: "login")
        ]
        return components.url!
    }
    
    var webOAuthUrl: URL {
        stravaAuthURL(base: "https://www.strava.com/oauth/authorize")
    }

    var appOAuthUrlStravaScheme: URL {
        stravaAuthURL(base: "strava://oauth/mobile/authorize")
    }
    
    func authenticate() async {
        print("🔑 authenticate() called")
        print("🔑 URL:", webOAuthUrl)
        if UIApplication.shared.canOpenURL(appOAuthUrlStravaScheme) {
            await UIApplication.shared.open(appOAuthUrlStravaScheme, options: [:])
        } else {
            do {
                let callbackURL = try await webSession.authenticate(
                    using: webOAuthUrl,
                    callbackURLScheme: Self.callbackScheme
                )
                print("🔑 Callback:", callbackURL)
                try await handleLogin(url: callbackURL)
                
                let token = await self.tokenStore.current()
                
                let tokenClaims = TokenService.decodeToken(token: token!)
                
                let isSpotifyScoped = hasSpotifyScope(scopes: tokenClaims.scopes!)
                
                print("IS SPOTIFY SCOPED: \(isSpotifyScoped)")
                
                print("AUTHED")
            } catch {
                print("🔑 Error:", error)
            }
        }
    }
    
    func hasSpotifyScope(scopes: [String]) -> Bool {
        let isSpotifyScoped = scopes.contains { scope in
            scope == "spotify"
        }
        return isSpotifyScoped
    }
 }
