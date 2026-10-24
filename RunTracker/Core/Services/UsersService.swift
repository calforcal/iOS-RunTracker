//
//  UsersService.swift
//  RunTracker
//
//  Created by Michael Callahan on 10/14/26.
//

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

}
