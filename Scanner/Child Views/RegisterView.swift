//
//  RegisterView.swift
//  Scanner
//
//  Created by Nick Molargik on 12/6/22.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @ObservedObject var viewModel : MainViewModel
    
    
    var body: some View {
        VStack {
            
            Capsule()
                .frame(width: 100, height: 5)
                .foregroundColor(.gray)
                .padding()
            
            SignUpHeader()
            
            Group {
                TextField("Email Address", text: $email)
                    .padding(.horizontal)
                    .keyboardType(.emailAddress)
                TextField("Username", text: $username)
                    .padding(.horizontal)
                SecureField("Password", text: $password)
                    .padding(.horizontal)
                    .border(password != confirmPassword ? Color.red : Color.clear)
                SecureField("Confirm password", text: $confirmPassword)
                    .padding(.horizontal)
                    .border(password != confirmPassword ? Color.red : Color.clear)
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
                    print("A -- Registering new user")
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            // there was an error creating the user
                            print("Error creating user: \(error)")
                            self.errorMessage = error.localizedDescription
                        } else {
                            self.errorMessage = ""
                            // user was successfully created
                            if let authResult = authResult {
                                print("Successfully created user: \(authResult.user)")
                                let userId = authResult.user.uid
                                let db = Firestore.firestore()
                                let userRef = db.collection("users").document(userId)
                                userRef.setData(["username": username]) { err in
                                    if let err = err {
                                        print("Error writing document: \(err)")
                                    } else {
                                        print("Document successfully written!")
                                    }
                                }
                                dismiss()
                            }
                        }
                    }
                }
            }, label: {
                ZStack {
                    Capsule()
                        .frame(width: 100, height: 40)
                        .foregroundColor(.blue)
                    
                    Text("Submit")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            })
            .disabled(password != confirmPassword)
            .padding()
            
            Divider()
                .padding()
            
            Text("or login with :")
                .bold()
                .padding(.top)
            
            HStack {
                Group {
                    Button(action: {
                        playHaptic()
                        withAnimation {
                            print("Google")
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
                
            }
            .scaleEffect()
            .padding()
            
            Spacer()
        }
    }
}

struct SignUpHeader: View {
    var body: some View {
        Text("Sign Up")
            .fontWeight(.black)
            .italic()
            .font(.largeTitle)
            .shadow(radius: 2)
            .foregroundColor(Color("ModeOpposite"))
        
        Spacer()
        
        Text("Quickly create an account to enable community commenting and additional features in the future!")
            .multilineTextAlignment(.center)
            .padding()
        
        Text("Use an Email and Password:")
            .bold()
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(viewModel: MainViewModel())
    }
}
