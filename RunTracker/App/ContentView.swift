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

    @SwiftUI.Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @State private var healthResponse: String = ""
    @State private var errorMessage: String = ""
    @State private var loadingAPI: Bool = false
    
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
                await authService.authenticate()
                
                do {
                    let athlete = try await self.userService.fetchAthlete()
                    print("ATHLETE TOO: \(athlete)")
                } catch {
                    print("ERROR fetching athlete: \(error)")
                }
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
