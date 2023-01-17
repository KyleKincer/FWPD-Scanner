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
    @State var showPurchaseSheet = false
    @State var showingProfileEditor = false
    @State var username = ""
    @State var localError = ""
    @State var showAdminTools = false
    
    var body: some View {
        if (!viewModel.loggedIn) {
            // Authenticate
            if (signingUp) {
                RegisterView(viewModel: viewModel, signingUp: $signingUp, showPage: $viewModel.showAuth)
            } else {
                LoginView(viewModel: viewModel, signingUp: $signingUp, showPage: $viewModel.showAuth)
            }
            
        } else {
            VStack (alignment: .leading) {
                // Nav
                HStack {
                    
                    if (!showingProfileEditor) {
                        Button (action: {
                            withAnimation {
                                showProfileView.toggle()
                            }
                        }, label: {
                            BackButtonView(text: "Back", color: .orange)
                        })
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                viewModel.logOut()
                                
                                
                                if (viewModel.loginType == "google") {
                                    viewModel.googleSignOut()
                                }
                                
                                viewModel.loggedIn = false
                                viewModel.showAuth = true
                            }
                        }, label: {
                            Text("Sign Out")
                                .foregroundColor(.red)
                                .padding([.top, .trailing])
                                .shadow(radius: 10)
                        })
                    }
                }
                
                // Profile view
                HStack (alignment: .top) {
                    VStack {
                        
                        if (viewModel.currentUser!.admin) {
                            Image(systemName: "crown")
                                .foregroundColor(.red)
                                .onTapGesture(perform: {
                                    showAdminTools = true
                                })
                        }
                        
                        ProfilePhoto(url: viewModel.currentUser?.profileImageURL, size: 100)
                        
                        if (!showingProfileEditor) {
                            Button {
                                withAnimation {
                                    showingProfileEditor = true
                                }
                            } label: {
                                ZStack {
                                    Capsule(style: .circular)
                                        .strokeBorder(.gray)
                                        .clipped()
                                        .clipShape(Capsule())
                                        .frame(width: 85, height: 20)
                                        .shadow(radius: 10)
                                    
                                    Text("Edit profile")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    VStack (alignment: .center) {
                        Text(viewModel.currentUser?.username ?? "Username")
                            .font(.title)
                            .fontWeight(.bold)
                            .italic()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        if (showingProfileEditor) {
                            TextField(viewModel.currentUser?.username ?? "Username", text: $username)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.never)
                                .limitInputLength(value: $username, length: 20)
                                .transition(.move(edge: .trailing))
                                .frame(maxWidth: 200)
                                .padding(.horizontal)
                        }
                        
                        if (!showingProfileEditor && viewModel.currentUser?.bio != "") {
                            Text((viewModel.currentUser?.bio ?? ""))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .frame(maxWidth: 400)
                                
                        }
                        
                        if (!showingProfileEditor && viewModel.currentUser?.createdAt != nil && viewModel.currentUser?.createdAt != "") {
                            Text("Member since " + (viewModel.currentUser?.createdAt)!)
                                .padding(.top)
                        }
                        
                        if (!showingProfileEditor && (viewModel.currentUser?.twitterHandle != "" || viewModel.currentUser?.instagramHandle != "" || viewModel.currentUser?.tiktokHandle != "")) {
                            
                            HStack {
                                if (viewModel.currentUser?.twitterHandle != "") {
                                    Image("twitter")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                                
                                if (viewModel.currentUser?.instagramHandle != "") {
                                    Image("instagram")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                                
                                if (viewModel.currentUser?.tiktokHandle != "") {
                                    Image("tiktok")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding()
                
                if (localError != "") {
                    HStack {
                        Spacer()
                        
                        Text(localError)
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }

                Spacer()
                
                if (showingProfileEditor) {
                    ProfileEditView(viewModel: viewModel, username: $username, showingProfileEditor: $showingProfileEditor, localError: $localError)
                        .transition(.move(edge: .trailing))
                    
                } else {
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
                    .transition(.move(edge: .leading))
                }
            }
            .sheet(isPresented: $showPurchaseSheet) {
                PurchaseView(viewModel: viewModel)
            }
            .sheet(isPresented: $showAdminTools) {
                AdminToolsView(viewModel: viewModel)
            }
                
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: MainViewModel(), showProfileView: .constant(true))
    }
}
