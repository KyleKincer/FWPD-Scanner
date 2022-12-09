//
//  LoginViewModel.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/8/22.
//

import Foundation
import FirebaseAuth
import Firebase
import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    let email: String = ""
    let password: String = ""
    var errorMessage: String = ""
    
    @MainActor
    func login(email: String, password: String, viewModel: MainViewModel) -> Future<String, Error> {
        return Future { promise in
            do {
                print("A -- Logging in...")
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        // there was an error logging in
                        print("Error logging in: \(error)")
                        promise(.failure(error))
                    } else {
                        // user was successfully logged in
                        if let authResult = authResult {
                            let userId = authResult.user.uid
                            viewModel.userId = userId
                            
                            // Get the user's username from Firestore
                            Firestore.firestore().collection("users").document(userId).getDocument { (snapshot, error) in
                                if let error = error {
                                    // there was an error getting the username
                                    print("Error getting username: \(error)")
                                    promise(.failure(error))
                                } else {
                                    // the username was successfully retrieved
                                    if let snapshot = snapshot, let data = snapshot.data(), let username = data["username"] as? String {
                                        print("Successfully retrieved username: \(username)")
                                        viewModel.username = username
                                        promise(.success(("")))
                                    }
                                }
                            }
                            print("Successfully logged in user: \(userId)")
                        }
                    }
                    viewModel.loggedIn = true
                }
            }
        }
    }
}
