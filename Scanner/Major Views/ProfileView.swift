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
    @State var showPurchaseSheet = false
    @State var showAlert = false
    
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
                    
                    if let url = viewModel.currentUser?.profileImageURL {
                        ZStack {
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: 100, height: 100)
                            
                            AsyncImage(url: url) { image in
                                image
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.crop.circle")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 80))
                            }
                        }
                        
                    } else {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(.gray)
                            .font(.system(size: 80))
                            .onTapGesture {
                                showAlert = true
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Profile Picture"),
                                    message: Text("Log out and sign back in using Google to use your Google profile picture.")
                                )
                            }
                    }
                    
                    VStack {
                        if editingUsername {
                            VStack (alignment: .center){
                                TextField(viewModel.currentUser!.username, text: $newUsername)
                                    .frame(width: 200)
                                    .limitInputLength(value: $newUsername, length: 20)
                                    .textInputAutocapitalization(.never)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        withAnimation {
                                            onSubmit()
                                        }
                                    }
                                    .padding(.horizontal)
                                    .focused($usernameIsFocused)
                                    .border(Color.white)
                                
                                Button {
                                    withAnimation {
                                        onSubmit()
                                    }
                                } label: {
                                    ZStack {
                                        Capsule()
                                            .frame(width: 75, height: 40)
                                            .foregroundColor(.blue)
                                        
                                        Text("Save")
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                    }
                                }
                                .disabled(newUsername.count==0)
                                .padding(.horizontal)
                            }
                        } else {
                            HStack {
                                Text(viewModel.currentUser?.username ?? "Username")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .italic()
                                    .multilineTextAlignment(.center)
                                
                                Button {
                                    withAnimation {
                                        editingUsername = true
                                        newUsername = viewModel.currentUser!.username
                                        usernameIsFocused = true
                                    }
                                } label: {
                                    Text("Edit")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
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
                .padding(.horizontal)
                
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
