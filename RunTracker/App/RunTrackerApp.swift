//
//  RunTrackerApp.swift
//  RunTracker
//
//  Created by Michael Callahan on 5/9/26.
//


import SwiftUI
import Foundation

@Observable
class AppState {
    var athlete: Athlete? = nil
}

@main
struct RunTrackerApp: App {
    let userService: UsersService
    let authService: AuthService
    
    @State var appState = AppState()
    
    init() {
        let client = APIClient.shared
        userService = UsersService(client: client)
        authService = AuthService(client: client, webSession: ASWebAuthenticator()
        )
    }
    var body: some Scene {
        WindowGroup {
            Group {
                if let athlete = appState.athlete {
                    AthleteOverview(athlete: athlete)
                } else {
                    ContentView(
                        userService: userService,
                        authService: authService
                    )
                }
            }
            .environment(appState)
            .animation(.default, value: appState.athlete != nil)
        }
    }
}
