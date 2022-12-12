//
//  ProfileView.swift
//  Scanner
//
//  Created by Nick Molargik on 12/9/22.
//

import SwiftUI

struct ProfileView: View {
    @Binding var viewModel : MainViewModel
    @State private var signingUp = false
    @State private var page = 1
    @Binding var showProfileView : Bool
    @State private var editingUsername = false
    @State private var newUsername = ""
    @FocusState var usernameIsFocused: Bool
    
    
    var body: some View {
        if (viewModel.auth.loggedIn) {
            // Authenticate
            if (signingUp) {
                RegisterView(viewModel: viewModel, signingUp: $signingUp, showPage: $viewModel.auth.showAuth)
            } else {
                LoginView(viewModel: viewModel, signingUp: $signingUp, showPage: $viewModel.auth.showAuth)
            }
            
        } else {
            // Profile View
            VStack {
                HStack {
                    
                    Button (action: {
                        showProfileView.toggle()
                        
                    }, label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.orange)
                        
                        Text("Back")
                            .foregroundColor(.orange)
                        
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.auth.logOut()
                        viewModel.auth.loggedIn = false
                    }, label: {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    })
                    
                }
                .padding(.horizontal)
                
                Button (action: {
                    // Change icon color and send change to firebase?
                    
                }, label: {
                    if (viewModel.auth.profileImageURL != "") {
                        AsyncImage(url: URL(string: viewModel.auth.profileImageURL)) { image in
                            image
                                .clipShape(Circle())
                        } placeholder: {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(.gray)
                                .font(.system(size: 80))
                        }

                    } else {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(.gray)
                            .font(.system(size: 80))
                    }
                })
                if editingUsername {
                    HStack {
                        TextField(viewModel.auth.username, text: $newUsername)
                            .frame(width: 200)
                            .limitInputLength(value: $newUsername, length: 20)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.done)
                            .onSubmit {
                                onSubmit()
                            }
                            .padding(.horizontal)
                            .focused($usernameIsFocused)
                        
                        Button {
                            onSubmit()
                        } label: {
                            ZStack {
                                Capsule()
                                    .frame(width: 100, height: 40)
                                    .foregroundColor(.blue)
                                
                                Text("Submit")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        }.disabled(newUsername.count==0)
                    }
                } else {
                    HStack {
                        Text(viewModel.auth.username)
                            .font(.title2)
                        Button {
                            editingUsername = true
                            newUsername = viewModel.auth.username
                            usernameIsFocused = true
                        } label: {
//                            Text("Edit")
//                                .font(.footnote)
//                                .foregroundColor(.secondary)
                            
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                        }
                    }
                    
                }
                
                Divider()
                    .padding(.horizontal, 50)
                
                Spacer()
                
                
                TabView {
                    BookmarkView(viewModel: viewModel)
                        .tabItem {
                            Label("Bookmarks", systemImage: "bookmark")
                                .tint(.orange)
                        }
                        .badge(viewModel.bookmarkCount)
                    
                    HistoryView(viewModel: viewModel)
                        .tabItem {
                            Label("History", systemImage: "clock")
                                .foregroundColor(.blue)
                        }
                }
            }
        }
    }
    
    @MainActor
    func onSubmit() {
        if (newUsername != viewModel.auth.username && newUsername.count > 0) {
            viewModel.auth.updateUsername(to: newUsername)
        }
        editingUsername = false
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: .constant(MainViewModel()), showProfileView: .constant(true))
    }
}
