//
//  Constants.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/19/22.
//

import Foundation
import MapKit

enum Constants {
    // Activity API
    static let API_URL = "https://api.kylekincer.com"
    static let ACTIVITY_URL = API_URL + "/activity"
    static let PROXIMITY_URL = ACTIVITY_URL + "/proximity"
    
    // Location settings
    static let defaultLocation = CLLocationCoordinate2D(
        latitude: CLLocationDegrees(41.0793),
        longitude: CLLocationDegrees(-85.1394))
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.0075, longitudeDelta: 0.0075)
}
