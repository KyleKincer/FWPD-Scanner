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
    @ObservedObject var viewModel : MainViewModel
    @Binding var signingUp : Bool
    @Binding var showPage : Bool
    
    var body: some View {
        VStack {
            
            Group {
                HStack {
                    Button(action: {
                        withAnimation {
                            signingUp = false
                            showPage = false
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.yellow)
                                .font(.system(size: 30))
                            
                            Text("Back")
                                .foregroundColor(.yellow)
                        }
                    })
                    .padding([.leading, .top])
                    
                    Spacer()
                    
                }
                .padding(.horizontal)
                
            }
            
            Group {
                Text("Sign In")
                    .fontWeight(.black)
                    .italic()
                    .font(.largeTitle)
                    .shadow(radius: 2)
                    .foregroundColor(Color("ModeOpposite"))
                
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
            
            if errorMessage != "" {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .lineLimit(nil)
                    .padding(.horizontal)
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
                                viewModel.userId = userId
                                
                                // Get the user's username from Firestore
                                Firestore.firestore().collection("users").document(userId).getDocument { (snapshot, error) in
                                    if let error = error {
                                        // there was an error getting the username
                                        print("Error getting username: \(error)")
                                    } else {
                                        // the username was successfully retrieved
                                        if let snapshot = snapshot, let data = snapshot.data(), let username = data["username"] as? String {
                                            print("Successfully retrieved username: \(username)")
                                            viewModel.username = username
                                        }
                                    }
                                }
                                print("Successfully logged in user: \(userId)")
                            }
                            viewModel.loggedIn = true
                            dismiss()
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
            
            Text("or")
                .font(.subheadline)
                .italic()
                .padding(.vertical, -5)
                .padding(.top, -4)
            
            Button(action: {
                playHaptic()
                withAnimation {
                    signingUp = true
                }
            }, label: {
                ZStack {
                    Capsule()
                        .frame(width: 100, height: 40)
                        .foregroundColor(.blue)
                    
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            })
            
            Group {
                
                Divider()
                    .padding()
                
                Text("or use any of the following services:")
                    .bold()
                    .padding()
                
                HStack {
                    Group {
                        Button(action: {
                            playHaptic()
                            withAnimation {
                                viewModel.loginWithGoogle()
                                withAnimation {
                                    dismiss()
                                }
                            }
                        }, label: {
                            Image("googleLogo")
                        })
                        .scaleEffect(0.2)
                        .frame(width: 50, height: 50)
                        .padding()
                        
                        Button(action: {
                            playHaptic()
                            withAnimation {
                                print("Facebook")
                            }
                        }, label: {
                            Image("facebookLogo")
                        })
                        .scaleEffect(0.35)
                        .frame(width: 50, height: 50)
                        .padding()
                        
                        Button(action: {
                            playHaptic()
                            withAnimation {
                                print("Twitter")
                            }
                        }, label: {
                            Image("twitterLogo")
                        })
                        .scaleEffect(0.08)
                        .frame(width: 50, height: 50)
                        .padding()
                        
                        Button(action: {
                            playHaptic()
                            withAnimation {
                                print("Apple")
                            }
                        }, label: {
                            Image("appleLogo")
                                .background(Color.white)
                                .cornerRadius(200)
                        })
                        .scaleEffect(0.4)
                        .frame(width: 50, height: 50)
                        .padding()
                    }
                }.padding()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: MainViewModel(), signingUp: .constant(false), showPage: .constant(true))
    }
}
