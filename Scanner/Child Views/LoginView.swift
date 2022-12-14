//
//  LoginView.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/6/22.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var googleAuth = false
    @ObservedObject var viewModel : MainViewModel
    @Binding var signingUp : Bool
    @Binding var showPage : Bool
    @State var showPasswordForgot = false
    @State private var resetting = false
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    signingUp = false
                    showPage = false
                    dismiss()
                }
            }, label: {
                BackButtonView(text: "Cancel", color: Color.orange)
            })
                    
            Spacer()
            
            Group {
                Text("Sign In")
                    .fontWeight(.black)
                    .italic()
                    .font(.largeTitle)
                    .shadow(radius: 2)
                    .foregroundColor(Color("ModeOpposite"))
                
                Image(systemName: "person.3.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                    .shadow(radius: 5)
                
                Spacer()
            
            }
            
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
            
            Button(action: {
                showPasswordForgot.toggle()
            }, label: {
                Text("Forgot your Password?")
                    .foregroundColor(.blue)
                    .padding()
            })
            
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
                        .frame(width: 100, height: 40)
                        .foregroundColor(.blue)
                    
                    Text("Sign In")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            })
            .padding(.top)
            .frame(maxWidth: 350)
            
            Group {
                
                Divider()
                    .padding()
                
                Text("No Account?")
                    .bold()
                
                Button(action: {
                    playHaptic()
                    withAnimation {
                        signingUp = true
                    }
                }, label: {
                    ZStack {
                        Capsule()
                            .frame(width: 200, height: 40)
                            .foregroundColor(.blue)
                        
                        Text("Sign Up with Email")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                })
                
                HStack {
                    Group {
                        
                        if (googleAuth) {
                            ProgressView()
                                .scaleEffect(2.5)
                                .frame(width: 50, height: 50)
                                .padding()
                                .shadow(radius: 6)
                            
                        } else {
                            Button(action: {
                                playHaptic()
                                googleAuth.toggle()
                                withAnimation {
                                    viewModel.loginWithGoogle()
                                }
                            }, label: {
                                Image("googleLogo")
                            })
                            .scaleEffect(0.2)
                            .frame(width: 50, height: 50)
                            .padding()
                            .shadow(radius: 6)
                        }
                    }
                }
                
                Text("or sign up or in quickly with Google")
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showPasswordForgot) {
            VStack {
                Button(action: {
                    withAnimation {
                        email = ""
                        showPasswordForgot.toggle()
                    }
                }, label: {
                    BackButtonView(text: "Cancel", color: Color.blue)
                })
                
                Text("Forgot Your Password?")
                    .font(.title)
                    .padding()
                
                Spacer()
                
                Text("Provide your account email:")
                TextField("Account Email:", text: $email)
                    .frame(height: 50)
                    .padding(.horizontal)
                    .autocapitalization(.none)
                
                Button(action: {
                    withAnimation {
                        resetting = true
                        Auth.auth().sendPasswordReset(withEmail: email) { error in
                            if (error?.localizedDescription ?? "" != "") {
                                errorMessage = error!.localizedDescription
                            } else {
                                email = ""
                                showPasswordForgot.toggle()
                            }
                        }
                        resetting = false
                    }
                    
                }, label: {
                    if (resetting) {
                        ProgressView()
                            .scaleEffect(2)
                        
                    } else {
                        ZStack {
                            Capsule()
                                .frame(width: 220, height: 50)
                                .foregroundColor(.blue)
                            
                            Text("Request Password Reset")
                                .foregroundColor(.white)
                                
                        }
                        .opacity(email.count == 0 ? 0 : 1)
                    }
                })
                .disabled(resetting || email.count == 0)
                .padding()
                
                Spacer()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: MainViewModel(), signingUp: .constant(false), showPage: .constant(true))
    }
}
