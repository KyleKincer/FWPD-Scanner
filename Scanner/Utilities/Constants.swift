//
//  Constants.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/19/22.
//

import Foundation
import MapKit

enum Constants {
    // Location settings
    static let defaultLocation = CLLocationCoordinate2D(
        latitude: CLLocationDegrees(41.0793),
        longitude: CLLocationDegrees(-85.1394))
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.0075, longitudeDelta: 0.0075)
    static let defaultSpanLarge = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
    static let appID = "ca-app-pub-3358879278981317/4566147613"
    //    static let appID = "ca-app-pub-3940256099942544/2934735716" // TESTING APP ID
}

enum SetName: String {
    case activities
    case bookmarks
    case recentlyCommentedActivities
    case fires
}

enum AccountError: LocalizedError {
    case usernameTaken

    var errorDescription: String? {
        switch self {
        case .usernameTaken:
            return NSLocalizedString("This username is already taken", comment: "")
        }
    }
}

