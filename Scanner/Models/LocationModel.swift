//
//  LocationModel.swift
//  Scanner
//
//  Created by Nick Molargik on 12/12/22.
//

import Foundation
import MapKit

class LocationModel {
    @Published var locationManager: CLLocationManager = CLLocationManager()
    @Published var locationEnabled: Bool = false
    @Published var region = MKCoordinateRegion(center: Constants.defaultLocation, span: MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075))
}
