//
//  UsersService.swift
//  RunTracker
//
//  Created by Michael Callahan on 10/14/26.
//

import Foundation
import OpenAPIRuntime

struct UsersService {
    private let client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    func fetchHealth() async throws -> String {
        let response = try await client.getRoot()
        let body = try response.ok.body.plainText
        return try await String(collecting: body, upTo: 1024 * 1024)
    }
    
    func fetchAthlete() async throws -> Athlete {
        let response: Components.Schemas.AthleteResponse = try await client.getAthlete().ok.body.json
        guard let athlete = Athlete(response) else {
            throw URLError(.cannotParseResponse)
        }
        return athlete
    }
    
    func fetchListeningHistory() async throws -> ListeningHistory {
        let response: Components.Schemas.ListeningHistoryResponse = try await client.getListeningHistory().ok.body.json
        let listeningHistory = ListeningHistory(response)
        return listeningHistory
    }
}
