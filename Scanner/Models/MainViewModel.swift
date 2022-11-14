//
//  MainViewModel.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/13/22.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit

@MainActor
final class MainViewModel: ObservableObject {
    // Main Model
    @Published var model: Scanner
    @Published var activities = [Scanner.Activity]()
    @Published var bookmarks = [Scanner.Activity]()
    @Published var natures = [Scanner.Nature]()
    
    // Location and Map
    @Published var locationManager: CLLocationManager = CLLocationManager()
    @Published var locationEnabled: Bool = false
    @Published var region = MKCoordinateRegion(center: Constants.defaultLocation, span: MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075))
    
    // Filters
    @Published var selectedNatures = Set<String>() { didSet{ refresh() }}
    @Published var selectedNaturesString = [String]()
    @Published var notificationNatures = Set<String>() { didSet{ refresh() }}
    @Published var notificationNaturesString = [String]()
    @AppStorage("useLocation") var useLocation = false
    @AppStorage("useDate") var useDate = false
    @AppStorage("useNature") var useNature = false
    @AppStorage("radius") var radius = 0.0
    @AppStorage("dateFrom") var dateFrom = String()
    @AppStorage("dateTo") var dateTo = String()
    @AppStorage("selectedNatures") var selectedNaturesUD = String()
    
    // View States
    @Published var isRefreshing = false
    @Published var serverResponsive = true
    @Published var isLoading = false
    @Published var showBookmarks = false
    @Published var bookmarkCount = 0
    
    // Network
    @Published var networkManager = NetworkManager()
    
    // UserDefaults
    let defaults = UserDefaults.standard
    
    init() {
        print("Initializing list view model")
        model = Scanner()
        
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
                case .notDetermined, .restricted, .denied:
                    print("No access to location")
                    self.locationEnabled = false
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access to location confirmed")
                    self.locationEnabled = true
                @unknown default:
                    break
            }
        } else {
            print("Location services are not enabled")
        }
        
        let selectionArray = selectedNaturesUD.components(separatedBy: ", ")
        self.selectedNatures = Set(selectionArray)
        self.selectedNaturesString = Array(selectedNatures)
        
        self.bookmarkCount=defaults.object(forKey: "bookmarkCount") as? Int ?? 0
        print("Found \(self.bookmarkCount) bookmark(s)!")
    }
    
    func refresh() {
        print("Refreshing")
        self.showBookmarks = false
        self.isRefreshing = true
        self.isLoading = true
        self.activities.removeAll() // clear out stored activities
        self.bookmarks.removeAll() // clear out bookmark records
            
        
        
        Task.init {
            do {
                // Get first set of activities
                let newActivities = try await self.networkManager.getFirstActivities(filterByDate: self.useDate, filterByLocation: self.useLocation, filterByNature: self.useNature, dateFrom: self.dateFrom, dateTo: self.dateTo, selectedNatures: self.selectedNaturesString, location: self.locationManager.location, radius: self.radius)
                if (newActivities.count > 0) {
                    self.activities.append(contentsOf: newActivities)
                    print("Got activities")
                    self.serverResponsive = true
                    self.addDatesToActivities(setName: "activities")
                    self.addDistancesToActivities(setName: "activities")
                    self.isRefreshing = false
                    self.isLoading = false
                } else {
                    print("Got zero activities")
                    self.serverResponsive = false
                    self.isRefreshing = false
                    self.isLoading = false
                }
            }
        }
        self.getNatures()
        self.getBookmarks()
    }
    
    // Get next 25 activities from Firestore
    func getMoreActivities() {
        let radius = UserDefaults.standard.double(forKey: "radius")
        var location: CLLocation? = nil
        if UserDefaults.standard.bool(forKey: "useLocation") {
            location = self.locationManager.location
        }
        self.isLoading = true
        Task.init {
            do {
                let newActivities = try await self.networkManager.getMoreActivities(filterByDate: self.useDate, filterByLocation: self.useLocation, filterByNature: self.useNature, dateFrom: self.dateFrom, dateTo: self.dateTo, selectedNatures: self.selectedNaturesString, location: self.locationManager.location, radius: self.radius)
                
                if (newActivities.count > 0) {
                    self.activities.append(contentsOf: newActivities)
                    print("Got activities")
                    self.serverResponsive = true
                    self.addDatesToActivities(setName: "activities")
                    self.addDistancesToActivities(setName: "activities")
                    self.isLoading = false
                } else {
                    print("Got zero activities")
                    self.isLoading = false
                }
            }
        }
    }
    
    // Get natures from Firestore
    func getNatures() {
        Task.init {
            do {
                //Get natures if there aren't any
                let newNatures = try await self.networkManager.getNatures()
                if (newNatures.count > 0) {
                    self.natures = newNatures
                    print("Got natures")
                }
            }
        }
    }
    
    func addDatesToActivities(setName: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:SS"
        if (setName == "activities") {
            var set = self.activities
            for i in set.indices {
                set[i].date = formatter.date(from: set[i].timestamp)
            }
            self.activities = set
            
        } else {
            var set = self.bookmarks
            for i in set.indices {
                set[i].date = formatter.date(from: set[i].timestamp)
            }
            self.bookmarks = set
        }
    }
    
    func addDistancesToActivities(setName: String) {
        if let location = self.locationManager.location {
            if (setName == "activities") {
                var set = self.activities
                for i in set.indices {
                    set[i].distance = ((location.distance(
                        from: CLLocation(latitude: set[i].latitude, longitude: set[i].longitude))) * 0.000621371)
                }
                self.activities = set
            } else {
                var set = self.bookmarks
                for i in set.indices {
                    set[i].distance = ((location.distance(
                        from: CLLocation(latitude: set[i].latitude, longitude: set[i].longitude))) * 0.000621371)
                }
                self.bookmarks = set
            }
        }
    }
    
    func clearDistancesFromActivities() {
        for i in self.activities.indices {
            self.activities[i].distance = nil
        }
    }
    
    
    // Bookmark Controls
    
    //addBookmark
    func addBookmark(bookmark : Scanner.Activity) {
        var bookmarks = defaults.object(forKey: "Bookmarks") as? [String] ?? []
        bookmarks.append(String(bookmark.controlNumber))
        defaults.set(bookmarks, forKey: "Bookmarks")
        
        self.bookmarks.append(bookmark)
        
        self.bookmarkCount = defaults.object(forKey: "bookmarkCount") as? Int ?? 0
        self.bookmarkCount += 1
        print("Now have \(String(self.bookmarkCount)) bookmarks")
        defaults.set(self.bookmarkCount, forKey: "bookmarkCount")
    }
    
    
    //removeBookmark
    func removeBookmark(bookmark : Scanner.Activity) {
        var bookmarks = defaults.object(forKey: "Bookmarks") as? [String]
        bookmarks?.removeAll { $0 == bookmark.controlNumber}
        defaults.set(bookmarks, forKey: "Bookmarks")
        
        self.bookmarks.removeAll { $0.controlNumber == bookmark.controlNumber}
        
        self.bookmarkCount = defaults.object(forKey: "bookmarkCount") as? Int ?? 0
        self.bookmarkCount-=1
        if self.bookmarkCount < 0 {
            self.bookmarkCount = 0
        }
        defaults.set(self.bookmarkCount, forKey: "bookmarkCount")
        print("Now have \(String(self.bookmarkCount)) bookmarks")
        if self.bookmarkCount == 0 && self.showBookmarks {
            self.showBookmarks = false
            self.refresh()
        }
    }
    
    //checkBookmark
    func checkBookmark(bookmark : Scanner.Activity) -> Bool {
        let bookmarks = defaults.object(forKey: "Bookmarks") as? [String]
        let index = bookmarks?.firstIndex {$0 == bookmark.controlNumber}
        
        if index != nil {
            return true
        } else {
            return false
        }
    }
    
    //getBookmarks
    func getBookmarks() {
        let bookmarks = (defaults.object(forKey: "Bookmarks") as? [String])
        if (self.bookmarkCount > 0 && self.bookmarks.count != bookmarkCount) {
            Task.init {
                do {
                    //Get bookmarks
                    let bookmarks = try await self.networkManager.getActivitySet(controlNumbers: bookmarks!)
                    self.bookmarks = bookmarks
                    self.addDatesToActivities(setName: "bookmarks")
                    self.addDistancesToActivities(setName: "bookmarks")
                    print("Got bookmarks")
                }
            }
        }
    }
}
