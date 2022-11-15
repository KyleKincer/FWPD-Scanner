//
//  WatchDataModel.swift
//  WatchScanner Watch App
//
//  Created by Nick Molargik on 11/15/22.
//
import Foundation
import SwiftUI
import CoreLocation
import MapKit
import WatchKit

@MainActor
final class MainViewModelWatch: ObservableObject {
    // Main Model
    @Published var model: Scanner
    @Published var activities = [Scanner.Activity]()
    var watch = WKInterfaceDevice()
    
    // Location and Map
    @Published var locationManager: CLLocationManager = CLLocationManager()
    @Published var locationEnabled: Bool = false
    @Published var region = MKCoordinateRegion(center: Constants.defaultLocation, span: MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075))
    
    // Filters
    @AppStorage("useLocation") var useLocation = false
    @AppStorage("useDate") var useDate = false
    @AppStorage("useNature") var useNature = false
    @AppStorage("radius") var radius = 0.0
    @AppStorage("dateFrom") var dateFrom = String()
    @AppStorage("dateTo") var dateTo = String()
    
    // View States
    @Published var isRefreshing = false
    @Published var serverResponsive = true
    @Published var isLoading = false
    @Published var showBookmarks = false
    @Published var bookmarkCount = 0
    @Published var hapticsEnabled = true
    
    // Network
    @Published var networkManagerWatch = NetworkManagerWatch()
    
    // UserDefaults
    let defaults = UserDefaults.standard
    
    init() {
        print("I - Initializing list view model")
        model = Scanner()
        
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined, .restricted, .denied:
                print("X - Failed to get location")
                self.locationEnabled = false
            case .authorizedAlways, .authorizedWhenInUse:
                print("G - Succeeded in getting location ")
                self.locationEnabled = true
            @unknown default:
                break
            }
        } else {
            print("X - Location services are disabled by user")
        }
        
        self.refreshWatch()
        
    }
    
    func refreshWatch() {
        print("R --- Refreshing")
        self.isRefreshing = true
        self.isLoading = true
        self.activities.removeAll()
        
        Task.init {
            do {
                self.activities = try await self.networkManagerWatch.getActivities()
                self.addDatesToActivities(setName: "activities")
                self.addDistancesToActivities(setName: "activities")
                self.isLoading = false
                self.isRefreshing = false
            }
        }
    }
    
    func getMoreActiviesWatch() {
        print("+ --- Getting more activities")
        self.isLoading = true
        
        Task.init {
            do {
                let newActivities = try await self.networkManagerWatch.getMoreActivities()
                self.activities.append(contentsOf: newActivities)
                self.addDatesToActivities(setName: "activities")
                self.addDistancesToActivities(setName: "activities")
                self.isLoading = false
            }
        }
    }
    
    func addDatesToActivities(setName: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:SS"
        var set = self.activities
        for i in set.indices {
            set[i].date = formatter.date(from: set[i].timestamp)
        }
        self.activities = set
        print("G - Set dates on activities")
    }
    
    func addDistancesToActivities(setName: String) {
        if let location = self.locationManager.location {
            var set = self.activities
            for i in set.indices {
                set[i].distance = ((location.distance(
                    from: CLLocation(latitude: set[i].latitude, longitude: set[i].longitude))) * 0.000621371)
            }
            self.activities = set
            print("G - Set distances on activities")
        }
    }
    
    func clearDistancesFromActivities() {
        for i in self.activities.indices {
            self.activities[i].distance = nil
        }
    }
    
    func playHaptic() {
        if (self.hapticsEnabled) {
            self.watch.play(.success)
        }
    }
}


struct Response: Codable {
    struct Document: Codable {
        struct Fields: Codable {
            struct Nature: Codable {
                var stringValue : String
            }
            struct Address: Codable {
                var stringValue : String
            }
            struct Timestamp: Codable {
                var stringValue : String
            }
            struct Geohash: Codable {
                var stringValue : String
            }
            struct ControlNumber: Codable {
                var stringValue : String
            }
            struct Latitude: Codable {
                var doubleValue : Double
            }
            struct Location: Codable {
                var stringValue : String
            }
            struct Longitude: Codable {
                var doubleValue : Double
            }
            
            var nature: Nature
            var address: Address
            var timestamp: Timestamp
            var geohash: Geohash
            var control_number: ControlNumber
            var latitude: Latitude
            var location: Location
            var longitude: Longitude
        }
        var name: String
        var fields: Fields
        var createTime: String
        var updateTime: String
    }
    
    var documents: [Document]
    var nextPageToken: String
}
