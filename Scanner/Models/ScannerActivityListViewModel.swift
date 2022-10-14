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

class MM : ObservableObject {
    @Published var region = MKCoordinateRegion(center: Constants.defaultLocation, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
}


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
    @Published var serverResponsive = true
    @Published var needScroll = false
    @Published var mapModel = MM()
    private var storedPages : [Int] = []
    private var thresholdIndex = 20
    private var currentPage = 1
    
    init() {
        model = Scanner()
        print("Initializing activities")
        
        locationManager.checkIfLocationServicesIsEnabled()
        self.currentPage = 0
        self.getActivities()
    }
    
    func getMoreActivities() {
        print("Pulling page \(self.currentPage)")
        self.needScroll = true
        self.getActivities()
        
        return
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
                    self.serverResponsive = true // No error
                    var activityIDs: [Int] = []
                    
                    for activity in activitiesAll {
                        activityIDs.append(activity.id)
                    }
                    activityIDs = activityIDs.unique
                    let activities = activitiesAll.filter({activityIDs.contains($0.id)})
                    self.storedPages.append(currentPage)
                    self.currentPage+=1
                    self.activities.append(contentsOf: activities)
                    self.addDatesToActivities(self.activities)
                    self.addDistancesToActivities(self.activities)
                    
                    self.isLoading = false
                    
                case .failure(let error):
                    self.serverResponsive = false // Server error
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
    
    func refresh() {
        print("Refresh")
        self.isLoading = true
        self.storedPages = []
        self.currentPage = 0
        self.activities.removeAll()
        
        if natures.isEmpty {
            self.getNatures()
        }
        self.getActivities()
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
