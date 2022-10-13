//
//  LocationManager.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/14/22.
//

import Foundation
import SwiftUI
import CoreLocation
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
        }
        else {
            // TODO: Make this into an alert
            print("Location services are disabled")
        }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // TODO: Make this into an alert
            print("Go to settings and enable location services for Scanner")
        case .denied:
            // TODO: Make this into an alert
            print("Go to settings and enable location services for Scanner")
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            break
        }

    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
