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
    @Published private(set) var activities = [Scanner.Activity]()
    @Published private(set) var natures = [Scanner.Nature]()
    @Published var selectedNatures = Set<Int>() { didSet{ refresh() }}
    @Published var dateFrom = Date()
    @Published var dateTo = Date()
    
    @Published private var alertItem: AlertItem?
    @Published private(set) var isLoading = false
    private var currentPage = 1
    
    init() {
        model = Scanner()
        locationManager.checkIfLocationServicesIsEnabled()
        refresh()
    }
    
    func getMoreActivitiesIfNeeded(currentActivity activity: Scanner.Activity?) {
        guard let activity = activity else {
            getActivities()
            return
        }
        
        let thresholdIndex = activities.index(activities.endIndex, offsetBy: -5)
        if activities.firstIndex(where: { $0.id == activity.id }) == thresholdIndex {
            getActivities()
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
            getNatures()
        }
        getActivities()
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
