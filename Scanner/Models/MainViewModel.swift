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
    @Published var natures = [Scanner.Nature]()
    
    // Location and Map
    @Published var locationManager: CLLocationManager = CLLocationManager()
    @Published var locationEnabled: Bool = false
    @Published var region = MKCoordinateRegion(center: Constants.defaultLocation, span: MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075))
    
    // Filters
    @Published var selectedNatures = Set<String>()
    @Published var selectedNaturesString = [String]()
    @Published var notificationNatures = Set<String>()
    @Published var notificationNaturesString = [String]()
    @AppStorage("notificationNatures") var notificationNaturesUD = String()
    @AppStorage("useLocation") var useLocation = false
    @AppStorage("useDate") var useDate = false
    @AppStorage("useNature") var useNature = false
    @AppStorage("radius") var radius = 0.0
    @AppStorage("dateFrom") var dateFrom = String()
    @AppStorage("dateTo") var dateTo = String()
    @AppStorage("selectedNatures") var selectedNaturesUD = String()
    @AppStorage("username") var username = String()
    @AppStorage("userId") var userId = String()
    @Published var onboarding = false
    
    
    // View States
    @Published var isRefreshing = false
    @Published var serverResponsive = true
    @Published var isLoading = false
    @Published var showBookmarks = false
    @Published var bookmarkCount = 0
    
    // Network and auth
    @Published var networkManager = NetworkManager()
    @AppStorage("loggedIn") var loggedIn = false
    @Published var user : User?
    @Published var authError = ""
    @Published var showAuth = false
    @Published var loginType = ""
    
    // UserDefaults
    let defaults = UserDefaults.standard
    
    init() {
        print("I - Initializing list view model")
        model = Scanner()
        if (self.userId == "") {
            self.onboarding = true
        }
        
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
        
        let selectionArray = selectedNaturesUD.components(separatedBy: ", ")
        self.selectedNatures = Set(selectionArray)
        self.selectedNaturesString = Array(selectedNatures)
        
        let notificationArray = notificationNaturesUD.components(separatedBy: ", ")
        self.notificationNatures = Set(notificationArray)
        self.notificationNaturesString = Array(notificationNatures)
        
        
        self.bookmarkCount=defaults.object(forKey: "bookmarkCount") as? Int ?? 0
        print("G - Found \(self.bookmarkCount) bookmark(s)!")
        self.refresh()
    }
    
    func login(email: String, password: String) {
        Task.init {
            do {
                print("A -- Logging in...")
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        // there was an error logging in
                        print("Error logging in: \(error)")
                    } else {
                        // user was successfully logged in
                        if let authResult = authResult {
                            let userId = authResult.user.uid
                            self.userId = userId
                            
                            // Get the user's username from Firestore
                            Firestore.firestore().collection("users").document(userId).getDocument { (snapshot, error) in
                                if let error = error {
                                    self.authError = error.localizedDescription
                                    // there was an error getting the username
                                    print("Error getting username: \(error)")
                                } else {
                                    // the username was successfully retrieved
                                    if let snapshot = snapshot, let data = snapshot.data(), let username = data["username"] as? String {
                                        print("Successfully retrieved username: \(username)")
                                        self.username = username
                                        self.loggedIn = true
                                        self.showAuth = false
                                        self.onboarding = false
                                        self.loginType = "email"
                                    }
                                }
                            }
                            print("Successfully logged in user: \(userId)")
                        }
                    }
                }
            }
        }
    }
    
    func loginWithGoogle() {
        // 1
          if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateUser(for: user, with: error)
            }
          } else {
            // 2
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            // 3
            let configuration = GIDConfiguration(clientID: clientID)
            
            // 4
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            // 5
            GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [unowned self] user, error in
              authenticateUser(for: user, with: error)
            }
              self.loginType = "google"
          }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
      // 1
      if let error = error {
        print(error.localizedDescription)
        return
      }
      
      // 2
      guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
      
      let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
      
      // 3
      Auth.auth().signIn(with: credential) { [unowned self] (result, error) in
        if let error = error {
          print(error.localizedDescription)
        } else {
            self.username = result!.user.displayName ?? "None"
            self.loggedIn = true
            self.showAuth = false
            self.onboarding = false
        }
      }
    }
    
    func googleSignOut() {
      // 1
      GIDSignIn.sharedInstance.signOut()
      
      do {
        // 2
        try Auth.auth().signOut()
        
          self.loggedIn = false
      } catch {
        print(error.localizedDescription)
      }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            self.username = ""
            self.userId = ""
            self.loggedIn = false
            self.onboarding = true
        } catch {
            print(error.localizedDescription)
        }
    }
       
    func refresh() {
        print("R --- Refreshing")
        self.showBookmarks = false
        self.isRefreshing = true
        self.activities.removeAll() // clear out stored activities
 
        Task.init {
            do {
                // Get first set of activities
                let newActivities = try await self.networkManager.getFirstActivities(filterByDate: self.useDate, filterByLocation: self.useLocation, filterByNature: self.useNature, dateFrom: self.dateFrom, dateTo: self.dateTo, selectedNatures: self.selectedNaturesString, location: self.locationManager.location, radius: self.radius)
                if (newActivities.count > 0) {
                    self.activities.append(contentsOf: newActivities)
                    print("+ --- Got activities")
                    
                    
                    withAnimation {
                        self.serverResponsive = true
                        
                        self.addDatesToActivities(setName: "activities")
                        self.addDistancesToActivities(setName: "activities")
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
    
    func createUser(email: String, password: String, username: String) {
        Task.init {
            do {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        // there was an error creating the user
                        print("Error creating user: \(error)")
                        self.authError = error.localizedDescription
                    } else {
                        self.authError = ""
                        // user was successfully created
                        if let authResult = authResult {
                            print("Successfully created user: \(authResult.user)")
                            self.userId = authResult.user.uid
                            let db = Firestore.firestore()
                            let userRef = db.collection("users").document(self.userId)
                            userRef.setData(["username": username]) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    print("Document successfully written!")
                                }
                            }
                            self.loggedIn = true
                            self.showAuth = false
                            self.username = username
                            self.onboarding = false
                        }
                    }
                }
            }
        }
    }
    
    // Get next 25 activities from Firestore
    func getMoreActivities() {
        withAnimation {
            self.isLoading = true
        }
        
        Task.init {
            do {
                let newActivities = try await self.networkManager.getMoreActivities(filterByDate: self.useDate, filterByLocation: self.useLocation, filterByNature: self.useNature, dateFrom: self.dateFrom, dateTo: self.dateTo, selectedNatures: self.selectedNaturesString, location: self.locationManager.location, radius: self.radius)
                
                if (newActivities.count > 0) {
                    self.activities.append(contentsOf: newActivities)
                    print("+ --- Got more activities")
                    withAnimation {
                        self.serverResponsive = true
                        self.addDatesToActivities(setName: "activities")
                        self.addDistancesToActivities(setName: "activities")
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
    
    func addDatesToActivities(setName: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:SS"
        if (setName == "activities") {
            var set = self.activities
            for i in set.indices {
                set[i].date = formatter.date(from: set[i].timestamp)
            }
            self.activities = set
            print("G - Set dates on activities")
            
        } else {
            var set = self.bookmarks
            for i in set.indices {
                set[i].date = formatter.date(from: set[i].timestamp)
            }
            self.bookmarks = set
            print("G - Set dates on bookmarks")
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
                print("G - Set distances on activities")
            } else {
                var set = self.bookmarks
                for i in set.indices {
                    set[i].distance = ((location.distance(
                        from: CLLocation(latitude: set[i].latitude, longitude: set[i].longitude))) * 0.000621371)
                }
                self.bookmarks = set
                print("G - Set distances on bookmarks")
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
                    self.addDatesToActivities(setName: "bookmarks")
                    self.addDistancesToActivities(setName: "bookmarks")
                    print("+ --- Got bookmark entries from Firebase")
                }
            }
        } else {
            print("+ --- All bookmarks already accounted for")
        }
    }
}
