//
//  Activity.swift
//  RunTracker
//
//  Created by Michael Callahan on 11/7/26.
//

import Foundation
import CoreLocation

// MARK: - Supporting types

/// Hashable/Sendable stand-in for CLLocationCoordinate2D.
struct Coordinate: Hashable, Sendable {
    let latitude: Double
    let longitude: Double

    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Strava sends [lat, lng]; an empty array means no GPS.
    init?(_ latlng: [Double]?) {
        guard let latlng, latlng.count == 2 else { return nil }
        self.latitude = latlng[0]
        self.longitude = latlng[1]
    }
}

/// Common Strava sport types, with a fallback for everything else.
enum SportType: Hashable, Sendable {
    case run, trailRun, virtualRun
    case ride, mountainBikeRide, gravelRide, virtualRide, eBikeRide
    case walk, hike, swim
    case weightTraining, workout, yoga
    case other(String)

    init(_ raw: String?) {
        switch raw {
        case "Run": self = .run
        case "TrailRun": self = .trailRun
        case "VirtualRun": self = .virtualRun
        case "Ride": self = .ride
        case "MountainBikeRide": self = .mountainBikeRide
        case "GravelRide": self = .gravelRide
        case "VirtualRide": self = .virtualRide
        case "EBikeRide": self = .eBikeRide
        case "Walk": self = .walk
        case "Hike": self = .hike
        case "Swim": self = .swim
        case "WeightTraining": self = .weightTraining
        case "Workout": self = .workout
        case "Yoga": self = .yoga
        default: self = .other(raw ?? "Unknown")
        }
    }

    var displayName: String {
        switch self {
        case .run: "Run"
        case .trailRun: "Trail Run"
        case .virtualRun: "Virtual Run"
        case .ride: "Ride"
        case .mountainBikeRide: "Mountain Bike Ride"
        case .gravelRide: "Gravel Ride"
        case .virtualRide: "Virtual Ride"
        case .eBikeRide: "E-Bike Ride"
        case .walk: "Walk"
        case .hike: "Hike"
        case .swim: "Swim"
        case .weightTraining: "Weight Training"
        case .workout: "Workout"
        case .yoga: "Yoga"
        case .other(let raw): raw
        }
    }

    var isRun: Bool { [.run, .trailRun, .virtualRun].contains(self) }
    var isRide: Bool {
        [.ride, .mountainBikeRide, .gravelRide, .virtualRide, .eBikeRide].contains(self)
    }

    var systemImage: String {
        switch self {
        case .run, .trailRun, .virtualRun: "figure.run"
        case .ride, .gravelRide, .virtualRide, .eBikeRide: "figure.outdoor.cycle"
        case .mountainBikeRide: "bicycle"
        case .walk: "figure.walk"
        case .hike: "figure.hiking"
        case .swim: "figure.pool.swim"
        case .weightTraining: "dumbbell"
        case .yoga: "figure.yoga"
        case .workout, .other: "figure.mixed.cardio"
        }
    }
}
// MARK: - Activity

struct Activity: Identifiable, Hashable, Sendable {
    let id: Int64
    let athleteId: Int64?
    let name: String
    let sportType: SportType
    let workoutType: Int?

    // Time
    let startDate: Date
    let startDateLocal: Date?
    let timeZone: TimeZone?
    let movingTime: TimeInterval      // seconds
    let elapsedTime: TimeInterval     // seconds

    // Distance & elevation (meters)
    let distance: Double
    let totalElevationGain: Double

    // Location
    let startCoordinate: Coordinate?
    let endCoordinate: Coordinate?
    let city: String?
    let state: String?
    let country: String?
    let summaryPolyline: String?

    // Speed (meters/second)
    let averageSpeed: Double?
    let maxSpeed: Double?

    // Power & effort
    let averageCadence: Double?
    let averageWatts: Double?
    let weightedAverageWatts: Double?
    let maxWatts: Double?
    let kilojoules: Double?
    let hasPowerMeter: Bool
    let averageHeartRate: Double?
    let maxHeartRate: Double?
    let sufferScore: Double?

    // Social
    let kudosCount: Int
    let commentCount: Int
    let achievementCount: Int
    let prCount: Int
    let athleteCount: Int
    let photoCount: Int
    let hasKudoed: Bool

    // Flags
    let isTrainer: Bool
    let isCommute: Bool
    let isManual: Bool
    let isPrivate: Bool
    let isFlagged: Bool

    // Gear & sync
    let gearId: String?
    let externalId: String?
    let uploadId: Int64?
}

// MARK: - Helpers

extension Activity {
    /// When the activity ended. Handy for matching listening history.
    var endDate: Date { startDate.addingTimeInterval(elapsedTime) }

    var hasHeartRate: Bool { averageHeartRate != nil }
    var hasGPS: Bool { startCoordinate != nil }

    var distanceInKilometers: Double { distance / 1_000 }
    var distanceInMiles: Double { distance / 1_609.344 }

    var distanceMeasurement: Measurement<UnitLength> {
        Measurement(value: distance, unit: .meters)
    }

    var elevationMeasurement: Measurement<UnitLength> {
        Measurement(value: totalElevationGain, unit: .meters)
    }

    /// Seconds per kilometer, based on moving time.
    var paceSecondsPerKilometer: TimeInterval? {
        distance > 0 ? movingTime / distanceInKilometers : nil
    }

    /// Seconds per mile, based on moving time.
    var paceSecondsPerMile: TimeInterval? {
        distance > 0 ? movingTime / distanceInMiles : nil
    }

    /// "1:02:15" or "42:10".
    var formattedMovingTime: String {
        let pattern: Duration.TimeFormatStyle.Pattern =
            movingTime >= 3_600 ? .hourMinuteSecond : .minuteSecond
        return Duration.seconds(movingTime).formatted(.time(pattern: pattern))
    }

    var location: String? {
        let parts = [city, state, country].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}

// MARK: - Mapping

extension Activity {
    /// Returns nil if the response has no id or start date.
    init?(_ response: Components.Schemas.ActivityResponse) {
        guard let id = response.id, let startDate = response.start_date else { return nil }

        self.init(
            id: id,
            athleteId: response.athlete?.id,
            name: response.name ?? "Untitled activity",
            sportType: SportType(response.sport_type ?? response._type),
            workoutType: response.workout_type,
            startDate: startDate,
            startDateLocal: response.start_date_local,
            timeZone: Self.parseTimeZone(response.timezone),
            movingTime: TimeInterval(response.moving_time ?? 0),
            elapsedTime: TimeInterval(response.elapsed_time ?? 0),
            distance: response.distance ?? 0,
            totalElevationGain: response.total_elevation_gain ?? 0,
            startCoordinate: Coordinate(response.start_latlng),
            endCoordinate: Coordinate(response.end_latlng),
            city: response.location_city,
            state: response.location_state,
            country: response.location_country,
            summaryPolyline: response.map?.summary_polyline,
            averageSpeed: response.average_speed,
            maxSpeed: response.max_speed,
            averageCadence: response.average_cadence,
            averageWatts: response.average_watts,
            weightedAverageWatts: response.weighted_average_watts,
            maxWatts: response.max_watts,
            kilojoules: response.kilojoules,
            hasPowerMeter: response.device_watts ?? false,
            averageHeartRate: (response.has_heartrate ?? false) ? response.average_heartrate : nil,
            maxHeartRate: (response.has_heartrate ?? false) ? response.max_heartrate : nil,
            sufferScore: response.suffer_score,
            kudosCount: response.kudos_count ?? 0,
            commentCount: response.comment_count ?? 0,
            achievementCount: response.achievement_count ?? 0,
            prCount: response.pr_count ?? 0,
            athleteCount: response.athlete_count ?? 1,
            photoCount: response.total_photo_count ?? response.photo_count ?? 0,
            hasKudoed: response.has_kudoed ?? false,
            isTrainer: response.trainer ?? false,
            isCommute: response.commute ?? false,
            isManual: response.manual ?? false,
            isPrivate: response._private ?? false,
            isFlagged: response.flagged ?? false,
            gearId: response.gear_id,
            externalId: response.external_id,
            uploadId: response.upload_id
        )
    }

    /// Strava sends e.g. "(GMT-07:00) America/Denver".
    private static func parseTimeZone(_ raw: String?) -> TimeZone? {
        guard let identifier = raw?.split(separator: " ").last else { return nil }
        return TimeZone(identifier: String(identifier))
    }
}
