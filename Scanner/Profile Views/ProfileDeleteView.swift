//
//  ProfileDeleteView.swift
//  Scanner
//
//  Created by Nick Molargik on 2/6/23.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ProfileDeleteView: View {
    @State var deleting = false
    @State var showCredentials = false
    @ObservedObject var viewModel : MainViewModel
    @Binding var showDelete : Bool
    @State var email = ""
    @State var password = ""
    @State var errorMessage = ""
    @State private var googleAuth = false
    
    var body: some View {
        VStack {
            // Delete confirmation
            Text("Account Deletion")
                .fontWeight(.bold)
                .font(.title)
                .padding()
            
            if (!showCredentials) {
                if (!deleting) {
                    
                    Text("Account deletion is available to clear all of your personal data (name, profile picture, etc) from our database. This data is never shared with a third party, and is safe and sound with us. However, if you'd like to delete this data, you may.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("You will lose access to all profile-dependent features, such as bookmarking and commenting, until you make a new account. Any existing comments from you will be shown to others as Anonymous.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                    
                    ProfilePhoto(url: viewModel.currentUser?.profileImageURL, size: 50.0)
                        .scaleEffect(2)
                    
                    Spacer()
                    
                    Text("Are you sure you'd like to delete your account?")
                        .bold()
                    
                    HStack {
                        Button(action: {
                            // Dismiss sheet
                            withAnimation {
                                showDelete.toggle()
                            }
                        }, label: {
                            ZStack {
                                Capsule()
                                    .frame(width: 200, height: 40)
                                    .foregroundColor(.gray)
                                
                                Text("Cancel")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        })
                        
                        Button(action: {
                            withAnimation {
                                let user = Auth.auth().currentUser
                                deleting = true
                                
                                
                                viewModel.deleteUser(user: user, completion: { success in
                                    if (success) {
                                        withAnimation {
                                            viewModel.loggedIn = false
                                            viewModel.showAuth = true
                                            deleting = false
                                            showDelete = false
                                            viewModel.currentUser = nil
                                        }
                                    } else {
                                        // Prompt for new credentials
                                        withAnimation {
                                            deleting = false
                                            showCredentials = true
                                            playHaptic()
                                        }
                                    }
                                })
                            }
                            
                        }, label: {
                            ZStack {
                                Capsule()
                                    .frame(width: 100, height: 40)
                                    .foregroundColor(.red)
                                
                                Text("Delete")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        })
                    }
                } else {
                    Text("Deleting Account")
                        .bold()
                    
                    ProgressView()
                }
                    
            } else {
                    Text("ACTION REQUIRED")
                        .bold()
                        .padding()
                    
                    Text("To delete your information, you must provide your credentials one last time. Please continue below.")
                        .padding([.bottom, .horizontal])
                    
                    Text("Use your Email and Password:")
                        .bold()
                    
                    Group {
                        TextField("Email Address", text: $email)
                            .padding(.horizontal)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                            .padding(.horizontal)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    
                    if errorMessage != "" {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .onAppear {
                                playHaptic()
                            }
                    }
                    
                    Button(action: {
                        playHaptic()
                        withAnimation {
                            print("A -- Logging in...")
                            
                            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                                if let error = error {
                                    // there was an error logging in
                                    print("Error logging in: \(error)")
                                    self.errorMessage = error.localizedDescription
                                } else {
                                    self.errorMessage = ""
                                    // user was successfully logged in
                                    if let authResult = authResult {
                                        let userId = authResult.user.uid
                                        
                                        // Get the user's username from Firestore
                                        Firestore.firestore().collection("users").document(userId).getDocument { (snapshot, error) in
                                            if let error = error {
                                                // there was an error getting the username
                                                print("Error getting username: \(error)")
                                            } else {
                                                // the username was successfully retrieved
                                                if let snapshot = snapshot, let data = snapshot.data(), let username = data["username"] as? String {
                                                    print("Successfully retrieved username: \(username)")
                                                    viewModel.currentUser = User(document: snapshot)
                                                }
                                            }
                                        }
                                        print("Successfully logged in user: \(userId)")
                                        withAnimation {
                                            let user = Auth.auth().currentUser
                                            showCredentials = false
                                            deleting = true
                                            
                                            
                                            viewModel.deleteUser(user: user, completion: { success in
                                                if (success) {
                                                    withAnimation {
                                                        viewModel.loggedIn = false
                                                        viewModel.showAuth = true
                                                        deleting = false
                                                        showDelete = false
                                                        viewModel.currentUser = nil
                                                    }
                                                } else {
                                                    // Prompt for new credentials
                                                    withAnimation {
                                                        deleting = false
                                                        showCredentials = true
                                                        playHaptic()
                                                    }
                                                }
                                            })
                                        }
                                    }
                                    withAnimation {
                                        viewModel.loggedIn = true
                                    }
                                }
                            }
                        }
                    }, label: {
                        ZStack {
                            Capsule()
                                .frame(width: 200, height: 40)
                                .foregroundColor(.blue)
                                .shadow(radius: 10)
                            
                            Text("Delete Account")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                    })
                    .padding(.top)
                    .frame(maxWidth: 350)
                    
                    Group {
                        
                        Text("Or")
                        HStack {
                            Group {
                                
                                Button(action: {
                                    playHaptic()
                                    googleAuth.toggle()
                                    withAnimation {
                                        viewModel.loginWithGoogle()
                                        let user = Auth.auth().currentUser
                                        showCredentials = false
                                        deleting = true
                                        
                                        
                                        viewModel.deleteUser(user: user, completion: { success in
                                            if (success) {
                                                withAnimation {
                                                    viewModel.loggedIn = false
                                                    viewModel.showAuth = true
                                                    deleting = false
                                                    showDelete = false
                                                    viewModel.currentUser = nil
                                                }
                                            } else {
                                                // Prompt for new credentials
                                                withAnimation {
                                                    deleting = false
                                                    showCredentials = true
                                                    playHaptic()
                                                }
                                            }
                                        })
                                        
                                    }
                                }, label: {
                                    ZStack {
                                        Capsule()
                                            .cornerRadius(100)
                                            .shadow(radius: 10)
                                        
                                            .foregroundColor(Color("ModeOpposite"))
                                        HStack {
                                            
                                            if (googleAuth) {
                                                ProgressView()
                                                    .scaleEffect(2.5)
                                                    .frame(width: 50, height: 50)
                                                    .shadow(radius: 6)
                                                    .tint(Color.blue)
                                                    .transition(.scale)
                                                
                                            } else {
                                                
                                                Image("googleLogo")
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                                    .shadow(radius: 6)
                                                    .transition(.scale)
                                            }
                                            
                                            Text("Use Google")
                                                .fontWeight(.bold)
                                                .foregroundColor(Color("ModeOpposite"))
                                                .colorInvert()
                                            
                                        }
                                        
                                    }
                                    .frame(width: 200, height: 80)
                                })
                            }
                        }
                }
            }
        }
    }
}

struct ProfileDeleteView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileDeleteView(viewModel: MainViewModel(), showDelete: .constant(true))
    }
}
