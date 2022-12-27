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
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var email = ""
    @ObservedObject var viewModel : MainViewModel
    @Binding var signingUp : Bool
    @Binding var showPage : Bool
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    signingUp = false
                    showPage = false
                }
            }, label: {
                BackButtonView(text: "Log In Instead", color: Color.orange)
            })
                
            SignUpHeader()

            Group {
                TextField("Email Address", text: $email)
                    .padding(.horizontal)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                ZStack {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .limitInputLength(value: $username, length: 20)
                        .padding(.horizontal)
                    
                    Text("\(username.count)/20")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 30)
                }
                SecureField("Password", text: $password)
                    .border(password != confirmPassword ? Color.red : Color.clear)
                    .padding(.horizontal)
                
                SecureField("Confirm password", text: $confirmPassword)
                    .border(password != confirmPassword ? Color.red : Color.clear)
                    .padding(.horizontal)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(maxWidth: 350)
            
            if viewModel.authError != "" {
                Text(viewModel.authError)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }
            
            Group {
                Button(action: {
                    playHaptic()
                    withAnimation {
                        print("A -- Registering new user")
                        viewModel.createUser(email: email, password: password, username: username) { created in
                            if (created) {
                                dismiss()
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
                
                Spacer()
            }
        }
        .onDisappear() {
            viewModel.authError = "" // clear auth error on exit so we don't show it again if user trys to register again
        }
    }
}

struct SignUpHeader: View {
    var body: some View {
        Group {
            
            Spacer()
            
            Text("Sign Up")
                .fontWeight(.black)
                .italic()
                .font(.largeTitle)
                .shadow(radius: 2)
                .foregroundColor(Color("ModeOpposite"))

            Image(systemName: "person.fill.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.orange)
                .shadow(radius: 5)
            
            Spacer()

            Text("Quickly create an account to enable community commenting and view bookmarks, along with additional features in the future!")
                .multilineTextAlignment(.center)
                .padding()

            Text("Use an Email and Password:")
                .bold()
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(viewModel: MainViewModel(), signingUp: .constant(true), showPage: .constant(true))
    }
}
