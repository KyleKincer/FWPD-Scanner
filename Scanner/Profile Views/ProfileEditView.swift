//
//  ProfileEditView.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/23/22.
//

import SwiftUI
import FirebaseAuth

struct ProfileEditView: View {
    @ObservedObject var viewModel : MainViewModel
    @Binding var username: String
    @State var bio = ""
    @State var twitterHandle = ""
    @State var instagramHandle = ""
    @State var tiktokHandle = ""
    @Binding var showingProfileEditor: Bool
    @State var saving = false
    @Binding var localError: String
    @State var showDelete = false
    @State var deleting = false
    
    var body: some View {
        
        VStack(alignment: .center) {            
            List {
                // Bio
                HStack(alignment: .top) {
                    Text("Bio")
                    Spacer()
                    if #available(iOS 16.0, *) {
                        TextField(viewModel.currentUser?.bio ?? "Write a bit about yourself...", text: $bio, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...4)
                            .limitInputLength(value: $bio, length: 200)
                    } else {
                        TextField(viewModel.currentUser?.bio ?? "Write a bit about yourself...", text: $bio)
                            .textFieldStyle(.roundedBorder)
                            .limitInputLength(value: $bio, length: 200)
                    }
                }
                
                // Socials
                Section {
                    // Twitter
                    HStack {
                        Image("twitter")
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text("Twitter")
                        
                        Spacer()
                        
                        TextField(viewModel.currentUser?.twitterHandle ?? "", text: $twitterHandle)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .limitInputLength(value: $twitterHandle, length: 15)
                            .frame(width: 200)
                    }
                    // Instagram
                    HStack {
                        Image("instagram")
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text("Instagram")
                        
                        Spacer()
                        
                        TextField(viewModel.currentUser?.instagramHandle ?? "", text: $instagramHandle)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .limitInputLength(value: $instagramHandle, length: 30)
                            .frame(width: 200)
                    }
                    // TikTok
                    HStack {
                        Image("tiktok")
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text("TikTok")
                        
                        Spacer()
                        
                        TextField(viewModel.currentUser?.tiktokHandle ?? "", text: $tiktokHandle)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .limitInputLength(value: $tiktokHandle, length: 24)
                            .frame(width: 200)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .listRowBackground(Color(.clear))
            
            HStack {
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showDelete.toggle()
                    }
                    print("Starting account deletion workflow...")
                }, label: {
                    ZStack {
                        Capsule()
                            .frame(width: 200, height: 40)
                            .foregroundColor(.red)
                        
                        Text("Delete Account")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                })
                .padding(.bottom, 30)
                .padding(.top, 10)
                
                Spacer()
            }
            
            Spacer()
            
            // Submit
            if (saving) {
                ProgressView()
                    .tint(.blue)
                    .scaleEffect(2)
                
            } else {
                HStack {
                    Spacer()
                    
                    
                    Button {
                        withAnimation {
                            localError = ""
                            showingProfileEditor.toggle()
                        }
                    } label: {
                        ZStack {
                            Capsule()
                                .frame(width: 100, height: 40)
                                .foregroundColor(.gray)
                            
                            Text("Cancel")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    
                    
                    Button {
                        withAnimation {
                            saving = true
                            localError = ""
                        }
                        // Sanitize socials inputs
                        twitterHandle = twitterHandle.replacingOccurrences(of: "@", with: "")
                        instagramHandle = instagramHandle.replacingOccurrences(of: "@", with: "")
                        tiktokHandle = tiktokHandle.replacingOccurrences(of: "@", with: "")
                        
                        viewModel.updateUser(userInput: User(id: viewModel.currentUser!.id, username: username, bio: bio, twitterHandle: twitterHandle, instagramHandle: instagramHandle, tiktokHandle: tiktokHandle, admin: viewModel.currentUser?.admin, commentCount: viewModel.currentUser?.commentCount ?? 0)) { result in
                            switch result {
                            case .failure(let error):
                                print(error)
                                withAnimation {
                                    localError = error.localizedDescription
                                    saving = false
                                }
                                
                            case .success():
                                print("Local user information updated")
                                withAnimation {
                                    showingProfileEditor.toggle()
                                }
                            }
                        }
                    } label: {
                        ZStack {
                            Capsule()
                                .frame(width: 100, height: 40)
                                .foregroundColor(.blue)
                            
                            Text("Save")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                .onAppear() {
                    username = viewModel.currentUser?.username ?? ""
                    bio = viewModel.currentUser?.bio ?? ""
                    twitterHandle = viewModel.currentUser?.twitterHandle ?? ""
                    instagramHandle = viewModel.currentUser?.instagramHandle ?? ""
                    tiktokHandle = viewModel.currentUser?.tiktokHandle ?? ""
                }
            }
        }
        .sheet(isPresented: $showDelete, content: {
            VStack {
                // Delete confirmation
                Text("Account Deletion")
                    .fontWeight(.bold)
                    .font(.title)
                    .padding()
                
                if (!deleting) {
                    
                    Text("Account deletion is available to clear all of your personal data (name, profile picture, etc) from our database. This data is never shared with a third party, and is safe and sound with us. However, if you'd like to delete this data, you may.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("You will lose access to all profile-dependent features, such as bookmarking and commenting, until you make a new account. Any existing comments from you will be shown to others as Anonymous.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                    
                    ProfilePhoto(url: viewModel.currentUser?.profileImageURL, size: 50.0)
                        .scaleEffect(5)
                    
                    Spacer()
                    
                    Text("Are you sure you'd like to delete your account?")
                        .bold()
                    
                    
                    HStack {
                        Button(action: {
                            // Dismiss sheet
                            withAnimation {
                                showDelete.toggle()
                            }
                        }, label: {
                            ZStack {
                                Capsule()
                                    .frame(width: 200, height: 40)
                                    .foregroundColor(.gray)
                                
                                Text("Cancel")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        })
                        
                        Button(action: {
                            withAnimation {
                                deleting = true
                                
                                let user = Auth.auth().currentUser
                                viewModel.deleteUser(user: user, completion: { success in
                                    if (success) {
                                        viewModel.loggedIn = false
                                        viewModel.showAuth = true
                                        deleting = false
                                        showDelete = false
                                    }
                                })
                            }
                            
                        }, label: {
                            ZStack {
                                Capsule()
                                    .frame(width: 100, height: 40)
                                    .foregroundColor(.red)
                                
                                Text("Delete")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        })
                    }
                } else {
                    Text("Deleting Account")
                        .bold()
                    
                    ProgressView()
                }
            }.interactiveDismissDisabled()
        })
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView(viewModel: MainViewModel(), username: .constant("poofy"), showingProfileEditor: .constant(true), localError: .constant("That username is already taken"))
            .environmentObject(AppDelegate())
    }
}
