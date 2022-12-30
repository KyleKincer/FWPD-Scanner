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
    
    var body: some View {
        if (!viewModel.loggedIn) {
            // Authenticate
            if (signingUp) {
                RegisterView(viewModel: viewModel, signingUp: $signingUp, showPage: $viewModel.showAuth)
            } else {
                LoginView(viewModel: viewModel, signingUp: $signingUp, showPage: $viewModel.showAuth)
            }
            
        } else {
            VStack {
                // Nav
                HStack {
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
                
                // Profile view
                HStack (alignment: .top) {
                    VStack {
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
                            .padding(.top, 10)
                        }
                    }
                    // Username
                    Text(viewModel.currentUser?.username ?? "Username")
                        .font(.title)
                        .fontWeight(.bold)
                        .italic()
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    //                    if (!editingUsername) {
                    //
                    //                        HStack (alignment: .center) {
                    //                            Button(action: {
                    //                                showPurchaseSheet.toggle()
                    //                            }, label: {
                    //                                Image(systemName: "dollarsign.square")
                    //                                    .foregroundColor(.white)
                    //                                    .padding(.trailing)
                    //                                    .shadow(radius: 5.0)
                    //                                    .font(.system(size: 30))
                    //                            })
                    //                        }
                    //                    }
                }
                .padding([.top, .horizontal])
                
                Divider()
                    .foregroundColor(.white)
                
                Spacer()
                
                if (showingProfileEditor) {
                    ProfileEditView(viewModel: viewModel, showingProfileEditor: $showingProfileEditor)
                        .transition(.opacity)
                    
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
                    .transition(.opacity)
                }
            }

            .sheet(isPresented: $showPurchaseSheet) {
                PurchaseView(viewModel: viewModel)
            }
//            .sheet(isPresented: $showingProfileEditor) {
//                if #available(iOS 16.0, *) {
//                    ProfileEditView(viewModel: viewModel)
//                        .presentationDetents([.large])
//                        .presentationDragIndicator(.visible)
//
//                } else {
//                    VStack {
//                        HStack {
//                            Button (action: {
//                                withAnimation {
//                                    showProfileView.toggle()
//                                }
//                            }, label: {
//                                BackButtonView(text: "Back", color: .orange)
//                            })
//
//                            Spacer()
//                        }
//
//                        ProfileEditView(viewModel: viewModel)
//                    }
//                }
//            }
        }
    }
    
    //    @MainActor
    //    func onSubmit() {
    //        if (newUsername != viewModel.currentUser?.username && newUsername.count > 0) {
    //            viewModel.usernameIsAvailable(username: newUsername, { available in
    //                if (available || newUsername == viewModel.currentUser?.username ?? "") {
    //                    viewModel.updateUsername(to: newUsername)
    //                    usernameError = ""
    //                    editingUsername = false
    //                } else {
    //                    usernameError = "This username is not available!"
    //                }
    //
    //            })
    //        }
    //    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: MainViewModel(), showProfileView: .constant(true))
    }
}
