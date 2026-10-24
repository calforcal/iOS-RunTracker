//
//  RunTrackerApp.swift
//  RunTracker
//
//  Created by Michael Callahan on 5/9/26.
//


import SwiftUI
import OpenAPIURLSession

@main
struct RunTrackerApp: App {
    let userService = UsersService(
        client: Client(
            serverURL: URL(string: "https://run-tracker-api-saqxt.ondigitalocean.app")!,
            transport: URLSessionTransport()
        )
    )
    let authService = AuthService(
        client: Client(
            serverURL: URL(string: "https://run-tracker-api-saqxt.ondigitalocean.app")!,
            transport: URLSessionTransport()
        )
    )
    var body: some Scene {
        WindowGroup {
            ContentView(
                userService: userService,
                authService: authService
            )
        }
    }
}
