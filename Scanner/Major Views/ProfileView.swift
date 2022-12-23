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
    @State var usernameError = ""
    
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
                    })
                    
                }
                
                HStack (alignment: .bottom) {
                    
                    VStack {
                        ProfilePhoto(url: viewModel.currentUser?.profileImageURL, size: 100)
                        
                        NavigationLink {
                            
                        } label: {
                            ZStack {
                                Capsule(style: .circular)
                                    .strokeBorder(.gray)
                                    .clipped()
                                    .clipShape(Capsule())
                                    .frame(width: 85, height: 20)
                                Text("Edit profile")
                                    .font(.footnote)
                                    .foregroundColor(.white)
                            }
                        }
                    }
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
            .sheet(isPresented: $showPurchaseSheet) {
                PurchaseView(viewModel: viewModel)
            }
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
