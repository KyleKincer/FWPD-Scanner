//
//  AuthModel.swift
//  Scanner
//
//  Created by Nick Molargik on 12/12/22.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

@MainActor
class AuthModel {
    @Published var user : User?
    @Published var authError = ""
    @Published var showAuth = false
    @Published var loginType = ""
    @Published var showAuthError = false
    
    @AppStorage("username") var username = String()
    @AppStorage("userId") var userId = String()
    @AppStorage("admin") var admin = false
    @AppStorage("profileImageURL") var profileImageURL = ""
    @AppStorage("loggedIn") var loggedIn = false
    
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
                self.profileImageURL = result!.user.photoURL?.absoluteString ?? ""
                initUser(auth: result)
            }
        }
    }
    
    func initUser(auth: AuthDataResult?) {
        self.userId = auth!.user.uid
        self.username = auth!.user.displayName ?? "None"
        self.loggedIn = true
        self.showAuth = false
        
        // Only call writeUserDocument if a document doesn't already exist
        // in the users collection with the uid.
        let userDocRef = Firestore.firestore().collection("users").document(self.userId)
        userDocRef.getDocument { (snapshot, error) in
            if error == nil && snapshot?.exists == false {
                self.writeUserDocument(userId: self.userId, username: self.username, imageURL: self.profileImageURL)
            } else if snapshot?.exists == true {
                self.readUserDocument(snapshot: snapshot!)
            }
        }
    }
    
    func readUserDocument(snapshot: DocumentSnapshot) {
        self.username = (snapshot.data()!["username"] as? String)!
        self.admin = snapshot.data()?["admin"] as? Bool ?? false
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
                                    self.userId = authResult.user.uid
                                    self.loggedIn = true
                                    self.showAuth = false
                                    self.username = username
                                    
                                    self.writeUserDocument(userId: self.userId, username: self.username, imageURL: self.profileImageURL)
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
    
    func writeUserDocument(userId: String, username: String, imageURL: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(self.userId)
        userRef.setData(["username": username, "imageURL": imageURL]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func updateUsername(to username: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(self.userId)
        let oldUserName = self.username
        self.username = username // preemptively set the local username property,
        
        userRef.updateData(["username": username]) { err in
            if let err = err {
                self.username = oldUserName
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            self.username = ""
            self.profileImageURL = ""
            self.userId = ""
            self.loggedIn = false
        } catch {
            print(error.localizedDescription)
        }
    }
}
