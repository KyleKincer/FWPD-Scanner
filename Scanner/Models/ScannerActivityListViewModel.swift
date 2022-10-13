//
//  ScannerActivityListViewModel.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/13/22.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit

final class ScannerActivityListViewModel: ObservableObject {
    @Published var locationManager: LocationManager = LocationManager()
    @Published var model: Scanner
    @Published var activities = [Scanner.Activity]()
    @Published var natures = [Scanner.Nature]()
    @Published var selectedNatures = Set<Int>() { didSet{ refresh() }}
    @Published var dateFrom = Date()
    @Published var dateTo = Date()
    @Published var region = MKCoordinateRegion(center: Constants.defaultLocation, span: MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075))
    @Published private var alertItem: AlertItem?
    @Published var isLoading = false
    private var currentPage = 1
    
    init() {
        print("Initializing activities")
        model = Scanner()
        locationManager.checkIfLocationServicesIsEnabled()
        self.refresh()
    }
    
    func getMoreActivitiesIfNeeded(currentActivity activity: Scanner.Activity?) {
        guard let activity = activity else {
            self.getActivities()
            return
        }
        
        let thresholdIndex = activities.index(activities.endIndex, offsetBy: -5)
        if activities.firstIndex(where: { $0.id == activity.id }) == thresholdIndex {
            self.getActivities()
        }
    }
    
    func getActivities() {
        let radius = UserDefaults.standard.double(forKey: "radius")
        var location: CLLocation? = nil
        if UserDefaults.standard.bool(forKey: "useLocation") {
            location = locationManager.locationManager?.location
        }
        NetworkManager.shared.getActivities(page: currentPage, dateFrom: dateFrom, dateTo: dateTo, natures: selectedNatures, location: location, radius: radius) { [self] result in
            
            DispatchQueue.main.async {
                switch result {
                    
                case .success(let activitiesAll):
                    var activityIDs: [Int] = []
                    
                    for activity in activitiesAll {
                        activityIDs.append(activity.id)
                    }
                    activityIDs = activityIDs.unique
                    let activities = activitiesAll.filter({activityIDs.contains($0.id)})
                    
                    self.activities.append(contentsOf: activities)
                    self.addDatesToActivities(self.activities)
                    self.addDistancesToActivities(self.activities)
                    self.currentPage+=1
                    self.isLoading = false
                case .failure(let error):
                    switch error {
                    case .invalidURL:
                        self.alertItem = AlertContext.invalidURL
                    case .unableToComplete:
                        self.alertItem = AlertContext.unableToComplete
                    case .invalidResponse:
                        self.alertItem = AlertContext.invalidResponse
                    case .invalidData:
                        self.alertItem = AlertContext.invalidData
                    }
                }
            }
            
        }
    }
    
    func getNatures() {
        NetworkManager.shared.getNatures { [self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let natures):
                    self.natures = natures
                case .failure(let error):
                    switch error {
                    case .invalidURL:
                        self.alertItem = AlertContext.invalidURL
                    case .unableToComplete:
                        self.alertItem = AlertContext.unableToComplete
                    case .invalidResponse:
                        self.alertItem = AlertContext.invalidResponse
                    case .invalidData:
                        self.alertItem = AlertContext.invalidData
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
    
    func addDistancesToActivities(_ activities: Array<Scanner.Activity>) {
        if let location = locationManager.locationManager?.location {
            for i in activities.indices {
                self.activities[i].distance = ((location.distance(
                    from: CLLocation(latitude: activities[i].latitude, longitude: activities[i].longitude))) * 0.000621371)
            }
        }
    }
    
    func clearDistancesFromActivities() {
        for i in activities.indices {
            self.activities[i].distance = nil
        }
    }
    
    // MARK: Intents
    
    func refresh() {
        print("Refresh")
        self.isLoading = true
        self.activities.removeAll()
        self.currentPage = 1
        if natures.isEmpty {
            self.getNatures()
        }
        self.getActivities()
        self.isLoading = false
    }
}

extension Array where Element: Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            guard !uniqueValues.contains(item) else { return }
            uniqueValues.append(item)
        }
        return uniqueValues
    }
}
