//
//  ActivityListItem.swift
//  RunTracker
//
//  Created by Michael Callahan on 11/8/26.
//

import SwiftUI

struct ActivityListItem: View {
    let activity: Activity
    
    var body: some View {
        let distanceKilometers = (activity.distance / 1000)
        let duration = Duration.seconds(activity.movingTime)
        let formattedDuration = duration.formatted(
            .time(pattern: .hourMinuteSecond(padHourToLength: 2))
        )
        
        VStack(alignment: .leading) {
            Text("\(activity.name)")
            Text("\(activity.sportType)")
            Text("Distance: \(distanceKilometers, format: .number.precision(.fractionLength(2))) KM")
            Text("Time: \(formattedDuration)")
        }
    }
}
