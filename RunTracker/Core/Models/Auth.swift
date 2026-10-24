//
//  Auth.swift
//  RunTracker
//
//  Created by Michael Callahan on 10/23/26.
//

struct AuthToken {
    let accessToken: String
}

extension AuthToken {
    init(_ dto: Components.Schemas.TokenResponse) {
        self.accessToken = dto.access_token
    }
}
