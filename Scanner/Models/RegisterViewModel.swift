//
//  RegisterViewModel.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/8/22.
//

import Foundation
import Firebase
import FirebaseAuth


class RegisterViewModel: ObservableObject {
    @Published var email = ""
    @Published var username = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""

    func createUser() -> Bool {
        var success = true
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // there was an error creating the user
                print("Error creating user: \(error)")
                self.errorMessage = error.localizedDescription
                success = false
            } else {
                self.errorMessage = ""
                // user was successfully created
                if let authResult = authResult {
                    print("Successfully created user: \(authResult.user)")
                    let userId = authResult.user.uid
                    let db = Firestore.firestore()
                    let userRef = db.collection("users").document(userId)
                    userRef.setData(["username": self.username]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
            }
        }
        return success
    }
}
