//
//  LoginView.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/6/22.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var viewModel : MainViewModel
    
    var body: some View {
        VStack {
            
            Group {
                Capsule()
                    .frame(width: 100, height: 5)
                    .foregroundColor(.gray)
                    .padding()
                
                Spacer()
                
                Text("Sign In")
                    .fontWeight(.black)
                    .italic()
                    .font(.largeTitle)
                    .shadow(radius: 2)
                    .foregroundColor(Color("ModeOpposite"))
                
                Spacer()
                
                Text("Sign in to enable community commenting and additional features in the future!")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Text("Use your Email and Password:")
                .bold()
            
            Group {
                TextField("Email Address", text: $email)
                    .padding(.horizontal)
                SecureField("Password", text: $password)
                    .padding(.horizontal)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                playHaptic()
                withAnimation {
                    print("A -- Registering new user")
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
            .padding()
            
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
                            .background(Color.white)
                            .cornerRadius(200)
                    })
                    .scaleEffect(0.4)
                    .frame(width: 50, height: 50)
                    .padding()
                }

            }.padding()
            
            Spacer()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: MainViewModel())
    }
}
