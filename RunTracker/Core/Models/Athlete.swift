//
//  Athlete.swift
//  RunTracker
///Users/michaelcallahan/Documents/personal/projects/RunTracker/RunTracker/Core/Services/UsersService.swift
//  Created by Michael Callahan on 11/3/26.
//

import Foundation

// MARK: - Gear (bikes and shoes share the same shape)

struct Gear: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let isPrimary: Bool
    let distance: Double          // meters

    var distanceInKilometers: Double { distance / 1_000 }
    var distanceInMiles: Double { distance / 1_609.344 }
}

extension Gear {
    init?(_ response: Components.Schemas.BikeResponse) {
        guard let id = response.id else { return nil }
        self.init(
            id: id,
            name: response.name ?? "Unnamed bike",
            isPrimary: response.primary ?? false,
            distance: response.distance ?? 0
        )
    }

    init?(_ response: Components.Schemas.ShoeResponse) {
        guard let id = response.id else { return nil }
        self.init(
            id: id,
            name: response.name ?? "Unnamed shoes",
            isPrimary: response.primary ?? false,
            distance: response.distance ?? 0
        )
    }
}

// MARK: - Athlete

struct Athlete: Identifiable, Hashable, Sendable {
    let id: Int64
    let username: String?
    let firstName: String
    let lastName: String
    let city: String?
    let state: String?
    let country: String?
    let sex: String?
    let isPremium: Bool
    let createdAt: Date?
    let updatedAt: Date?
    let badgeTypeId: Int?
    let profileImageURL: URL?
    let profileImageMediumURL: URL?
    let isFriend: Bool
    let isFollower: Bool
    let followerCount: Int
    let friendCount: Int
    let mutualFriendCount: Int
    let athleteType: Int?
    let datePreference: String?
    let measurementPreference: String?
    let ftp: Double?
    let weight: Double?           // kilograms
    let bikes: [Gear]
    let shoes: [Gear]
    let isSpotifyConnected: Bool

    var fullName: String {
        [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
    }

    var location: String? {
        let parts = [city, state, country].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    var usesMetric: Bool { measurementPreference == "meters" }

    var primaryBike: Gear? { bikes.first(where: \.isPrimary) }
    var primaryShoes: Gear? { shoes.first(where: \.isPrimary) }
}

extension Athlete {
    /// Maps the generated OpenAPI response into the app's model.
    /// Returns nil if the response has no id.
    init?(_ response: Components.Schemas.AthleteResponse) {
        guard let id = response.id else { return nil }
        self.init(
            id: id,
            username: response.username,
            firstName: response.firstname ?? "",
            lastName: response.lastname ?? "",
            city: response.city,
            state: response.state,
            country: response.country,
            sex: response.sex,
            isPremium: response.premium ?? false,
            createdAt: response.created_at,
            updatedAt: response.updated_at,
            badgeTypeId: response.badge_type_id,
            profileImageURL: response.profile.flatMap(URL.init(string:)),
            profileImageMediumURL: response.profile_medium.flatMap(URL.init(string:)),
            isFriend: response.friend ?? false,
            isFollower: response.follower ?? false,
            followerCount: response.follower_count ?? 0,
            friendCount: response.friend_count ?? 0,
            mutualFriendCount: response.mutual_friend_count ?? 0,
            athleteType: response.athlete_type,
            datePreference: response.date_preference,
            measurementPreference: response.measurement_preference,
            ftp: response.ftp,
            weight: response.weight,
            bikes: (response.bikes ?? []).compactMap(Gear.init),
            shoes: (response.shoes ?? []).compactMap(Gear.init),
            isSpotifyConnected: response.is_spotify_connected ?? false
        )
    }
}
