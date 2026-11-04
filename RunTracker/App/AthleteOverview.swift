//
//  AthleteOverview.swift
//  RunTracker
//
//  Created by Michael Callahan on 11/3/26.
//

import SwiftUI

struct AthleteOverview: View {
    let athlete: Athlete
    
    init(athlete: Athlete) {
        self.athlete = athlete
    }
    
    var body: some View {
        VStack {
            Text("Hello, \(athlete.fullName)")
        }
    }
}
