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
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

@MainActor
final class MainViewModel: ObservableObject {
    // Main Model
    @Published var model: Scanner
    @Published var activities = [Scanner.Activity]()
    @Published var bookmarks = [Scanner.Activity]()
    @Published var history = [Scanner.Activity]()
    @Published var recentlyCommentedActivities = [Scanner.Activity]()
    @Published var natures = [Scanner.Nature]()
    
    // Location and Map
    @Published var location = LocationModel()
    
    // Filters
    @Published var filters = FilterModel()
    
    // Network
    @Published var networkManager = NetworkManager()
    
    // Auth
    @Published var auth = AuthModel()
    
    // View States
    @Published var isRefreshing = false
    @Published var serverResponsive = true
    @Published var isLoading = false
    @Published var showBookmarks = false
    @Published var bookmarkCount = 0
    @Published var showMostRecent = false
    
    @Published var onboarding = false

    // UserDefaults
    let defaults = UserDefaults.standard
    
    init() {
        print("I - Initializing list view model")
        model = Scanner()
        
        if CLLocationManager.locationServicesEnabled() {
            switch self.location.locationManager.authorizationStatus {
            case .notDetermined, .restricted, .denied:
                print("X - Failed to get location")
                self.location.locationEnabled = false
            case .authorizedAlways, .authorizedWhenInUse:
                print("G - Succeeded in getting location ")
                self.location.locationEnabled = true
            @unknown default:
                break
            }
        } else {
            print("X - Location services are disabled by user")
        }
        
        let selectionArray = self.filters.selectedNaturesUD.components(separatedBy: ", ")
        self.filters.selectedNatures = Set(selectionArray)
        self.filters.selectedNaturesString = Array(self.filters.selectedNatures)
        
        let notificationArray = self.filters.notificationNaturesUD.components(separatedBy: ", ")
        self.filters.notificationNatures = Set(notificationArray)
        self.filters.notificationNaturesString = Array(self.filters.notificationNatures)
        
        self.bookmarkCount=defaults.object(forKey: "bookmarkCount") as? Int ?? 0
        print("G - Found \(self.bookmarkCount) bookmark(s)!")
        self.refresh()
    }
    
    // Refresh all data
    func refresh() {
        print("R --- Refreshing")
        self.showBookmarks = false
        self.isRefreshing = true
        self.activities.removeAll() // clear out stored activities
        
        Task.init {
            do {
                // Get first set of activities
                let newActivities = try await self.networkManager.getFirstActivities(filterByDate: self.filters.useDate, filterByLocation: self.filters.useLocation, filterByNature: self.filters.useNature, dateFrom: self.filters.dateFrom, dateTo: self.filters.dateTo, selectedNatures: self.filters.selectedNaturesString, location: self.location.locationManager.location, radius: self.filters.radius)
                if (newActivities.count > 0) {
                    self.activities.append(contentsOf: newActivities)
                    print("+ --- Got activities")
                    
                    
                    withAnimation {
                        self.serverResponsive = true
                        
                        self.addDatesToActivities(.activities)
                        self.addDistancesToActivities(.activities)
                        self.isRefreshing = false
                    }
                } else {
                    print("+ --- Got zero activities")
                    
                    withAnimation {
                        self.serverResponsive = false
                        self.isRefreshing = false
                    }
                }
            }
        }
        self.getNatures()
        self.getBookmarks()
    }

    // Get next 25 activities from Firestore
    func getMoreActivities() {
        withAnimation {
            self.isLoading = true
        }
        
        Task.init {
            do {
                let newActivities = try await self.networkManager.getMoreActivities(filterByDate: self.filters.useDate, filterByLocation: self.filters.useLocation, filterByNature: self.filters.useNature, dateFrom: self.filters.dateFrom, dateTo: self.filters.dateTo, selectedNatures: self.filters.selectedNaturesString, location: self.location.locationManager.location, radius: self.filters.radius)
                
                if (newActivities.count > 0) {
                    self.activities.append(contentsOf: newActivities)
                    print("+ --- Got more activities")
                    withAnimation {
                        self.serverResponsive = true
                        self.addDatesToActivities(.activities)
                        self.addDistancesToActivities(.activities)
                        self.isLoading = false
                    }
                } else {
                    print("+ --- Got more but zero activities")
                    withAnimation {
                        self.isLoading = false
                    }
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
                    print("+ --- Got natures")
                } else {
                    print("+ --- Got zero natures")
                }
            }
        }
    }
    
    func addDatesToActivities(_ setName: SetName) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:SS"
        switch setName {
        case .activities:
            var set = self.activities
            for i in set.indices {
                set[i].date = formatter.date(from: set[i].timestamp)
            }
            self.activities = set
            print("G - Set dates on activities")
        case .bookmarks:
            var set = self.bookmarks
            for i in set.indices {
                set[i].date = formatter.date(from: set[i].timestamp)
            }
            self.bookmarks = set
            print("G - Set dates on bookmarks")
        case .recentlyCommentedActivities:
            var set = self.recentlyCommentedActivities
            for i in set.indices {
                set[i].date = formatter.date(from: set[i].timestamp)
            }
            self.recentlyCommentedActivities = set
            print("G - Set dates on recentlyCommentedActivities")
        }
    }
    
    func addDistancesToActivities(_ setName: SetName) {
        if let location = self.location.locationManager.location {
            switch setName{
            case .activities:
                var set = self.activities
                for i in set.indices {
                    set[i].distance = ((location.distance(
                        from: CLLocation(latitude: set[i].latitude, longitude: set[i].longitude))) * 0.000621371)
                }
                self.activities = set
                print("G - Set distances on activities")
            case .bookmarks:
                var set = self.bookmarks
                for i in set.indices {
                    set[i].distance = ((location.distance(
                        from: CLLocation(latitude: set[i].latitude, longitude: set[i].longitude))) * 0.000621371)
                }
                self.bookmarks = set
                print("G - Set distances on bookmarks")
            case .recentlyCommentedActivities:
                var set = self.recentlyCommentedActivities
                for i in set.indices {
                    set[i].distance = ((location.distance(
                        from: CLLocation(latitude: set[i].latitude, longitude: set[i].longitude))) * 0.000621371)
                }
                self.recentlyCommentedActivities = set
                print("G - Set distances on recentlyCommentedActivities")
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
        print("G - Now have \(String(self.bookmarkCount)) bookmarks")
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
        print("G - Now have \(String(self.bookmarkCount)) bookmarks")
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
                    self.addDatesToActivities(.bookmarks)
                    self.addDistancesToActivities(.bookmarks)
                    print("+ --- Got bookmark entries from Firebase")
                }
            }
        } else {
            print("+ --- All bookmarks already accounted for")
        }
    }
    
    func getRecentlyCommentedActivities() {
        Task.init {
            do {
                //Get bookmarks
                let recentlyCommentedActivities = try await self.networkManager.getRecentlyCommentedActivities()
                self.recentlyCommentedActivities = recentlyCommentedActivities
                self.addDatesToActivities(.recentlyCommentedActivities)
                self.addDistancesToActivities(.recentlyCommentedActivities)
                print("+ --- Got recentlyCommentedActivities from Firebase")
            }
        }
    }
}
