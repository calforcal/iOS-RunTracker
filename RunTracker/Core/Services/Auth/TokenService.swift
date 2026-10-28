//
//  TokenService.swift
//  RunTracker
//
//  Created by Michael Callahan on 10/27/26.
//

import JWTDecode
import Foundation

struct TokenClaims: Decodable {
    var scopes: [String]?
}

enum TokenService {
    static func decodeToken(token: String) -> TokenClaims {
        var tokenClaims = TokenClaims(
            scopes: []
        )
        do {
            let jwt = try decode(jwt: token)
            
            if let scopes = jwt.claim(name: "scopes").string {
                tokenClaims.scopes = scopes.components(separatedBy: " ")
            }
        } catch {
            print("Error decoding token: \(error)")
        }
        return tokenClaims
    }
}
