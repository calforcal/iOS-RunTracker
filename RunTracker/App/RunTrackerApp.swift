//
//  RunTrackerApp.swift
//  RunTracker
//
//  Created by Michael Callahan on 5/9/26.
//


import SwiftUI

@main
struct RunTrackerApp: App {
    let userService: UsersService
    let authService: AuthService
    
    init() {
        let client = APIClient.shared
        userService = UsersService(client: client)
        authService = AuthService(client: client, webSession: ASWebAuthenticator()
        )
    }
    var body: some Scene {
        WindowGroup {
            ContentView(
                userService: userService,
                authService: authService
            )
        }
    }
}
