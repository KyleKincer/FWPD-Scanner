//
//  RegisterView.swift
//  Scanner
//
//  Created by Nick Molargik on 12/6/22.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var viewModel : MainViewModel
    
    
    var body: some View {
        VStack {
            
            Capsule()
                .frame(width: 100, height: 5)
                .foregroundColor(.gray)
                .padding()
            
            Group {
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
                
                TextField("Email Address", text: $email)
                    .padding(.horizontal)
                SecureField("Password", text: $password)
                    .padding(.horizontal)
            }
                
                Button(action: {
                    playHaptic()
                    withAnimation {
                        print("A -- Registering new user")
                        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                            // ... add code
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
                .padding()
            
            Spacer()
                    
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
                    })
                    .scaleEffect(0.1)
                    .frame(width: 50, height: 50)
                    .padding()
                }

            }.padding()
            
            Spacer()
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(viewModel: MainViewModel())
    }
}
