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
import CoreData

class MM : ObservableObject {
    @Published var region = MKCoordinateRegion(center: Constants.defaultLocation, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
}

final class MainViewModel: ObservableObject {
    @Published var locationManager: CLLocationManager = CLLocationManager()
    @Published var locationEnabled: Bool = false
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
    @Published var showBookmarks = false
    @Published var bookmarkCount = 0
    let defaults = UserDefaults.standard
    private var storedPages : [Int] = []
    private var currentPage = 1
    
    init() {
        print("Initializing list view model")
        model = Scanner()
        
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
                case .notDetermined, .restricted, .denied:
                    print("No access to location")
                    self.locationEnabled = false
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                    self.locationEnabled = true
                @unknown default:
                    break
            }
        } else {
            print("Location services are not enabled")
        }
        
        self.bookmarkCount=defaults.object(forKey: "bookmarkCount") as? Int ?? 0
        print("Have \(self.bookmarkCount) bookmark(s)!")
        self.getActivities()
    }
    
    func refresh() {
        print("Refreshing Activities")
        self.showBookmarks = false
        self.isRefreshing = true
        self.activities.removeAll() // clear out stored activities
        self.storedPages.removeAll() // clear out page log
        self.currentPage = 1 // prep us to get page #1
        
        if natures.isEmpty {
            self.getNatures() // get natures if first time using app
        }
        
        self.getActivities() // get first batch of activities
    }
    
    func getActivity(controlNum: String) {
        NetworkManager.shared.getActivity(controlNum: controlNum) { result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let activity):
                    print(activity)
                case .failure(let error):
                    print("Failed to retrieve activity \(controlNum) - \(String(error.localizedDescription)).")
                }
            }
        }
    }
    
    func getActivities() {
        let radius = UserDefaults.standard.double(forKey: "radius")
        var location: CLLocation? = nil
        if UserDefaults.standard.bool(forKey: "useLocation") {
            location = self.locationManager.location
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
                    self.addDatesToActivities()
                    self.addDistancesToActivities()
                    self.bookmarkCount = self.defaults.object(forKey: "bookmarkCount") as? Int ?? 0
                    
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
    
    func addDatesToActivities() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:SS"
        for i in self.activities.indices {
            self.activities[i].date = formatter.date(from: self.activities[i].timestamp)
        }
    }
    
    func addDistancesToActivities() {
        if let location = self.locationManager.location {
            for i in self.activities.indices {
                self.activities[i].distance = ((location.distance(
                    from: CLLocation(latitude: self.activities[i].latitude, longitude: self.activities[i].longitude))) * 0.000621371)
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
        self.showBookmarks = true
        self.activities = []
        var controlNums = ""
        let bookmarks = defaults.object(forKey: "Bookmarks") as? [String]
        
        if (bookmarks?.count ?? 0 > 0) {
            for bookmark in bookmarks ?? [""] {
                // Create CSV String
                controlNums = controlNums + bookmark + ","
            }
            
            NetworkManager.shared.getActivitySet(controlNums: controlNums) { [self] result in
                switch result {
                    
                case .success(var bookmarkList):
                    print("Bookmarks retrieved")
                    
                    
                    for i in bookmarkList.indices {
                        bookmarkList[i].bookmarked = true
                    }
                    self.activities = bookmarkList
                    self.addDistancesToActivities()
                    self.addDatesToActivities()
                    print("Done")
                    
                case .failure(let error):
                    print("Failed to retrieve bookmarks")
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
                }
            }
        }
    }
}
