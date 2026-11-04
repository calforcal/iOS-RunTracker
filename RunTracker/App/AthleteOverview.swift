//
//  AthleteOverview.swift
//  RunTracker
//
//  Created by Michael Callahan on 11/3/26.
//

import SwiftUI

struct AthleteOverview: View {
    let athlete: Athlete
    let usersService: UsersService
    
    init(
        athlete: Athlete,
        usersService: UsersService
    ) {
        self.athlete = athlete
        self.usersService = usersService
    }
    
    @State private var listeningHistory = ListeningHistory(items: [])
    @State private var isLoadingListeningHistory = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Hello, \(athlete.fullName)!")
                    .padding()
                Spacer()
            }
            HStack {
                if athlete.isSpotifyConnected {
                    Text("Spotify Connected")
                } else {
                    Text("Spotify not connected yet.")
                }
            }
            List {
                Section { Text("Listening History") }
                if isLoadingListeningHistory {
                    ProgressView("Loading")
                } else {
                    ForEach(listeningHistory.items) { song in
                        Text("\(song.song.title) by \(song.song.artist)")
                    }
                }
            }
            Spacer()
        }
        .task {
            do {
                listeningHistory = try await usersService.fetchListeningHistory()
            } catch {
                print("Error fetching")
            }
            isLoadingListeningHistory = false
        }
    }
}

#Preview {
    let athlete = Athlete(Components.Schemas.AthleteResponse(id: 1, firstname: "Michael", lastname: "Callahan", is_spotify_connected: false))!
    AthleteOverview(athlete: athlete, usersService: UsersService(client: APIClient.shared))
}
