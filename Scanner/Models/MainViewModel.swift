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
    @Published var onboarding = false
    
    
    // View States
    @Published var isRefreshing = false
    @Published var serverResponsive = true
    @Published var isLoading = false
    @Published var showBookmarks = false
    @Published var bookmarkCount = 0
    @Published var showMostRecent = false
    @Published var showAuthError = false
    
    // Network and auth
    @Published var networkManager = NetworkManager()
    @AppStorage("loggedIn") var loggedIn = false
    @Published var currentUser : User?
    @Published var authError = ""
    @Published var showAuth = false
    @Published var loginType = ""
    
    // UserDefaults
    let defaults = UserDefaults.standard
    
    init() {
        print("I - Initializing list view model")
        model = Scanner()
        if (!self.loggedIn) {
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
                            self.loginType = "email"
                            self.initUser(auth: authResult)
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
            self.showAuthError = true
            self.authError = error.localizedDescription
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
                self.currentUser?.profileImageURL = result!.user.photoURL ?? URL(string: "")
                self.currentUser = (User(id: result!.user.uid,
                                         username: result!.user.displayName!,
                                         profileImageURL: (result?.user.photoURL)!))
                initUser(auth: result)
            }
        }
    }
    
    func initUser(auth: AuthDataResult?) {
        self.loggedIn = true
        self.showAuth = false
        
        // Only call writeUserDocument if a document doesn't already exist
        // in the users collection with the uid.
        let userDocRef = Firestore.firestore().collection("users").document(self.currentUser!.id)
        userDocRef.getDocument { (snapshot, error) in
            if error == nil && snapshot?.exists == false {
                self.writeUserDocument(user: self.currentUser!)
            } else if snapshot?.exists == true {
                self.currentUser = User(document: snapshot!)
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
            self.loggedIn = false
            self.currentUser = nil
            
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
    
    func createUser(email: String, password: String, username: String, _ completion: @escaping (Bool) -> Void) {
        usernameIsAvailable(username: username, { available in
            if (!available) {
                self.authError = "Username is already in use."
                completion(false)
                return
            } else {
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
                                    self.loggedIn = true
                                    self.showAuth = false
                                    let newUser = User(username: username)
                                    self.currentUser = newUser
                                    
                                    self.writeUserDocument(user: newUser)
                                    completion(true)
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func usernameIsAvailable(username: String, _ completion: @escaping (Bool) -> Void) {
        // Get a reference to the users collection
        let db = Firestore.firestore()
        let usersRef = db.collection("users")
        
        // Create a query to get the user document with the specified username
        let query = usersRef.whereField("username", isEqualTo: username)
        
        // Get the query snapshot
        query.getDocuments() { snapshot, error in
            if let error = error {
                // there was an error querying the collection
                print("Error querying users collection: \(error)")
                completion(false)
            } else {
                // check if a user document with the specified username was found
                if snapshot!.documents.count > 0 {
                    // a user document with the specified username already exists
                    print("A user with the username '\(username)' already exists.")
                    completion(false)
                } else {
                    // the username is available
                    completion(true)
                }
            }
        }
    }
    
    func writeUserDocument(user: User) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)
        userRef.setData(["username": user.username, "imageURL": user.profileImageURL ?? URL(string: "")]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func updateUsername(to username: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(self.currentUser!.id)
        let oldUserName = (self.currentUser?.username)!
        self.currentUser?.username = username // preemptively set the local username property,
        
        userRef.updateData(["username": username]) { err in
            if let err = err {
                self.currentUser?.username = oldUserName
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
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
        if let location = self.locationManager.location {
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
