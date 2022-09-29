//
//  ScannerActivityListViewModel.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/13/22.
//

import Foundation
import SwiftUI
import CoreLocation

final class ScannerActivityListViewModel: ObservableObject {
    @Published private var locationManager: LocationManager = LocationManager()
    @Published private var model: Scanner
    @Published private(set) var activities: [Scanner.Activity] = []
    @Published private var alertItem: AlertItem?
    @Published private(set) var isLoading = false
    
    init() {
        model = Scanner()
        locationManager.checkIfLocationServicesIsEnabled()
        refresh()
    }
    
    func getActivitiesWithinProximity(location: CLLocation, radius: Double) {
        isLoading = true
        NetworkManager.shared.getActivitiesWithinProximity(location: location, radius: radius) { [self] result in
            
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let activities):
                    self.activities = activities
                    addDatesToActivities(self.activities)
                case .failure(let error):
                    switch error {
                    case .invalidURL:
                        alertItem = AlertContext.invalidURL
                    case .unableToComplete:
                        alertItem = AlertContext.unableToComplete
                    case .invalidResponse:
                        alertItem = AlertContext.invalidResponse
                    case .invalidData:
                        alertItem = AlertContext.invalidData
                    }
                }
            }
            
        }
    }
    
    func getActivities() {
        
        NetworkManager.shared.getActivities { [self] result in
            
            DispatchQueue.main.async {
                switch result {
                    
                case .success(let activities):
                    self.activities = activities
                    addDatesToActivities(self.activities)
                case .failure(let error):
                    switch error {
                    case .invalidURL:
                        alertItem = AlertContext.invalidURL
                    case .unableToComplete:
                        alertItem = AlertContext.unableToComplete
                    case .invalidResponse:
                        alertItem = AlertContext.invalidResponse
                    case .invalidData:
                        alertItem = AlertContext.invalidData
                    }
                }
            }
            
        }
    }
    
    func addDatesToActivities(_ activities: Array<Scanner.Activity>) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:SS"
        for i in activities.indices {
            self.activities[i].date = formatter.date(from: self.activities[i].timestamp)
        }
    }
    
    // MARK: Intents
    
    func refresh() {
        if let location = locationManager.locationManager?.location, UserDefaults.standard.bool(forKey: "useLocation") {
            print(UserDefaults.standard.double(forKey: "radius"))
            getActivitiesWithinProximity(location: location, radius: UserDefaults.standard.double(forKey: "radius"))
        } else {
            getActivities()
        }
    }
}
