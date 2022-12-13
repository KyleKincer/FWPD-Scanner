//
//  ProfileView.swift
//  Scanner
//
//  Created by Nick Molargik on 12/9/22.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel : MainViewModel
    @State private var signingUp = false
    @Binding var showProfileView : Bool
    @State private var editingUsername = false
    @State private var newUsername = ""
    @FocusState var usernameIsFocused: Bool
    
    var body: some View {
        if (!viewModel.loggedIn) {
            // Authenticate
            if (signingUp) {
                RegisterView(viewModel: viewModel, signingUp: $signingUp, showPage: $viewModel.showAuth)
            } else {
                LoginView(viewModel: viewModel, signingUp: $signingUp, showPage: $viewModel.showAuth)
            }
            
        } else {
            // Profile View
            VStack {
                HStack {
                    
                    Button (action: {
                        withAnimation {
                            showProfileView.toggle()
                        }
                        
                        
                    }, label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.orange)
                        
                        Text("Back")
                            .foregroundColor(.orange)
                        
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            viewModel.logOut()
                            viewModel.loggedIn = false
                            viewModel.showAuth = true
                        }
                    }, label: {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    })
                    
                }
                .padding(.horizontal)
                
                Button (action: {
                    // Change icon color and send change to firebase?
                    
                }, label: {
                    if (viewModel.currentUser?.profileImageURL != nil) {
                        AsyncImage(url: URL(string: viewModel.currentUser?.profileImageURL)) { image in
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
                        TextField(viewModel.currentUser?.username, text: $newUsername)
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
                                    .frame(width: 75, height: 40)
                                    .foregroundColor(.blue)
                                
                                Text("Save")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        }.disabled(newUsername.count==0)
                    }
                } else {
                    HStack {
                        Text(viewModel.username)
                            .font(.title2)
                        Button {
                            withAnimation {
                                editingUsername = true
                                newUsername = viewModel.currentUser?.username
                                usernameIsFocused = true
                            }
                        } label: {
                            Text("Edit")
                                .font(.footnote)
                                .foregroundColor(.secondary)
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
            .onDisappear {
                viewModel.refresh()
            }
        }
    }
    
    @MainActor
    func onSubmit() {
        if (newUsername != viewModel.currentUser?.username && newUsername.count > 0) {
            viewModel.updateUsername(to: newUsername)
        }
        editingUsername = false
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: MainViewModel(), showProfileView: .constant(true))
    }
}
