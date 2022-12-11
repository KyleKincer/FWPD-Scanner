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
                        showProfileView.toggle()
                        
                    }, label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.orange)
                        
                        Text("Back")
                            .foregroundColor(.orange)
                        
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.logOut()
                        viewModel.loggedIn = false
                    }, label: {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    })
                    
                }
                .padding(.horizontal)
                
                Button (action: {
                    // Change icon color and send change to firebase?
                    
                }, label: {
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(.gray)
                        .font(.system(size: 80))
                })
                if editingUsername {
                    HStack {
                        TextField(viewModel.username, text: $newUsername)
                            .frame(width: 200)
                            .limitInputLength(value: $newUsername, length: 20)
                            .padding(.horizontal)
                        
                        Button {
                            viewModel.updateUsername(to: newUsername)
                            editingUsername = false
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
                        Text(viewModel.username)
                            .font(.title2)
                        Button {
                            editingUsername = true
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
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: .constant(MainViewModel()), showProfileView: .constant(true))
    }
}
