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
}
