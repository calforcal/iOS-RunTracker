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
    @State private var activities = [Activity]()
    @State private var isFetchingData = false
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Hello, \(athlete.fullName)!")
                    .padding()
                Spacer()
            }
            List {
                if isFetchingData {
                    ProgressView("Loading")
                } else {
                    ForEach(listeningHistory.items) { song in
                        SongItem(listeningHistoryItem: song)
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .scrollContentBackground(.hidden)         // hide the List's default background
            .background(Color(red: 1.0, green: 0.89, blue: 0.88))
            Spacer()
            List {
                if isFetchingData {
                    ProgressView("Loading")
                } else {
                    ForEach(activities) { activity in
                        ActivityListItem(activity: activity)
                    }
                }
            }
            Spacer()
        }
        .task {
            do {
                listeningHistory = try await usersService.fetchListeningHistory()
                activities = try await usersService.fetchAthleteActivities()
            } catch {
                print("Error fetching")
            }
            isFetchingData = false
        }
    }
}

//#Preview {
//    let athlete = Athlete(Components.Schemas.AthleteResponse(id: 1, firstname: "Michael", lastname: "Callahan", is_spotify_connected: false))!
//    AthleteOverview(athlete: athlete, usersService: UsersService(client: APIClient.shared))
//}
