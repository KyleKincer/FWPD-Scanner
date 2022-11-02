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
    //static let API_URL = "http://10.0.0.178:80"
    static let ACTIVITY_URL = API_URL + "/activity"
    static let NATURE_URL = API_URL + "/nature"
    
    // Location settings
    static let defaultLocation = CLLocationCoordinate2D(
        latitude: CLLocationDegrees(41.0793),
        longitude: CLLocationDegrees(-85.1394))
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.0075, longitudeDelta: 0.0075)
    static let defaultSpanLarge = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
}
