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
    @Published var isRefreshing = false
    @Published var serverResponsive = true
    @Published var isLoading = false
    @Published var mapModel = MM()
    @FetchRequest(sortDescriptors: []) var bookmarks: FetchedResults<Bookmark>
    private var storedPages : [Int] = []
    private var currentPage = 1
    
    init() {
        print("Initializing list view model")
        model = Scanner()
        locationManager.checkIfLocationServicesIsEnabled()
        self.refresh()
    }
    
    func refresh() {
        print("Refreshing Activities")
        self.isRefreshing = true
        self.activities.removeAll() // clear out stored activities
        self.storedPages.removeAll() // clear out page log
        self.currentPage = 1 // prep us to get page #1
        
        if natures.isEmpty {
            self.getNatures() // get natures if first time using app
        }
        
        self.getActivities() // get first batch of activities
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
                    
                case .success(let newActivities):
                    print("Page \(self.currentPage) retrieved!")
                    self.serverResponsive = true // No problem connecting to server
                    self.isLoading = false
                    self.isRefreshing = false
                    self.storedPages.append(self.currentPage)
                    self.activities.append(contentsOf: newActivities)
//                    self.filterOutDuplicates()
                    self.addDatesToActivities(self.activities)
                    self.addDistancesToActivities(self.activities)
                    
                case .failure(let error):
                    print("Failed to retrieve Page \(self.currentPage)!")
                    self.serverResponsive = false // Indicate problem connecting to the server
                    
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
                    
                    self.getActivities() // Try again until we get some more activities
                }
            }
        }
    }
    
    func filterOutDuplicates() -> Void {
        let activityIDs = (self.activities).compactMap { $0.id }
        let uniqueIDs = Array(Set(activityIDs))
        var uniqueActivities = [Scanner.Activity]()
        
        for activityID in uniqueIDs {
            uniqueActivities.append(self.activities.first(where: {$0.id == activityID})!) // pile up all unique activities
        }
        
        self.activities = uniqueActivities
        return
    }
    
    func getMoreActivities() {
        self.isLoading = true
        self.currentPage+=1
        print("Asking for page \(self.currentPage) of activities...")
        self.getActivities()
        return
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
}
