//
//  Environment.swift
//  RunTracker
//
//  Created by Michael Callahan on 10/24/26.
//

import Foundation

enum Environment {
    static var stravaClientID: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "StravaClientID") as? String else {
            fatalError("StravaClientID missing from Info.plist mapping")
        }
        return key
    }
    
    static var appCallbackHost: String {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "AppCallbackHost") as? String else {
            fatalError("AppCallbackHost missing or invalid")
        }
        return urlString
    }
    
    static var appCallbackScheme: String {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "AppCallbackScheme") as? String else {
            fatalError("AppCallbackScheme missing or invalid")
        }
        return urlString
    }
}
