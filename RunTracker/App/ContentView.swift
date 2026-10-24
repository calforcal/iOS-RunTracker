//
//  ContentView.swift
//  RunTracker
//
//  Created by Michael Callahan on 5/9/26.
//

import SwiftUI
import AuthenticationServices


struct ContentView: View {
    let userService: UsersService
    let authService: AuthService

    init(
        userService: UsersService,
        authService: AuthService
    ) {
        self.userService = userService
        self.authService = authService
    }

    private static let callbackScheme = Environment.appCallbackScheme
    private static let stravaRedirectURI = "\(Environment.appCallbackScheme)://\(Environment.appCallbackHost)"

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

    private var webOAuthUrl: URL {
        stravaAuthURL(base: "https://www.strava.com/oauth/authorize")
    }

    private var appOAuthUrlStravaScheme: URL {
        stravaAuthURL(base: "strava://oauth/mobile/authorize")
    }

    @SwiftUI.Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @State private var healthResponse: String = ""
    @State private var errorMessage: String = ""
    @State private var loadingAPI: Bool = false

    private func authenticate() async {
        print("🔑 authenticate() called")
        print("🔑 URL:", webOAuthUrl)
        if UIApplication.shared.canOpenURL(appOAuthUrlStravaScheme) {
            await UIApplication.shared.open(appOAuthUrlStravaScheme, options: [:])
        } else {
            do {
                let callbackURL = try await webAuthenticationSession.authenticate(
                    using: webOAuthUrl,
                    callbackURLScheme: Self.callbackScheme
                )
                print("🔑 Callback:", callbackURL)
                try await authService.handleLogin(url: callbackURL)
                
                print("AUTHED")
            } catch {
                print("🔑 Error:", error)
                errorMessage = "Failed to authenticate"
            }
        }
    }
    
    private func exchangeStravaToken() async {
        
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    Overview()
                } label: {
                    VStack {
                        Text("Go to Overview")
                            .foregroundStyle(.pink)
                            .font(.system(size: 24))
                        if (loadingAPI) {
                            Text("BIG LOAD")
                        } else {
                            Text("Health Response: \(healthResponse)")
                        }
                    }
                    .padding()
                    .padding()
                    .background(.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .transition(.slide)
                }
            }
            .containerBackground(Color.pink, for: .navigation)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Run Tracker")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .padding()
                        .fixedSize()
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .task {
                do {
                    loadingAPI = true
                    healthResponse = try await userService.fetchHealth()
                    loadingAPI = false
                } catch {
                    errorMessage = "Failed to get health"
                }
            }
            .onOpenURL { url in
                Task {
                    do {
                        try await authService.handleLogin(url: url)
                    } catch {
                        print("Error exchanging login code: \(error)")
                    }
                }
            }
        }
        Button("Click") {
            Task {
                await authenticate()
            }
        }
    }
}

struct Overview: View {
    var body: some View {
        VStack {
            Text("Here I am Girl")
        }
    }
}
