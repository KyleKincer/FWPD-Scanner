//
//  ProfileEditView.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/23/22.
//

import SwiftUI

struct ProfileEditView: View {
    @ObservedObject var viewModel : MainViewModel
    @State var username = ""
    @State var bio = ""
    @State var twitterHandle = ""
    @State var instagramHandle = ""
    @State var tiktokHandle = ""
    
    var body: some View {
        
        VStack(alignment: .center) {
            Text("Edit profile")
                .font(.headline)
                .fontWeight(.bold)
                .italic()
                .padding(.bottom, 25)
            
            ProfilePhoto(url: viewModel.currentUser?.profileImageURL, size: 100)
        }
        .padding(.top, 30)
        
        List {
            // Username
            HStack {
                Text("Username")
                Spacer()
                TextField(viewModel.currentUser?.username ?? "Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .limitInputLength(value: $username, length: 20)
            }
            
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
                    // Fallback on earlier versions
                }
            }
            
            // Socials
            Section("Socials") {
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
            
            Section {
                // Submit
                HStack {
                    Spacer()
                    Button {
                        viewModel.updateUser(user: User(id: viewModel.currentUser!.id, username: username, bio: bio, twitterHandle: twitterHandle, instagramHandle: instagramHandle, tiktokHandle: tiktokHandle)) { result in
                            switch result {
                            case .failure(let error):
                                print(error)
                            
                            case .success():
                                print("Username is available")
                            }
                        }
                    } label: {
                        ZStack {
                            Capsule()
                                .frame(width: 100, height: 40)
                                .foregroundColor(.blue)
                            
                            Text("Submit")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                    }
                    Spacer()
                }
            }.listRowBackground(Color(.clear))
        }
        .listStyle(.insetGrouped)
        .onAppear() {
            username = viewModel.currentUser?.username ?? ""
            bio = viewModel.currentUser?.bio ?? ""
            twitterHandle = viewModel.currentUser?.twitterHandle ?? ""
            instagramHandle = viewModel.currentUser?.instagramHandle ?? ""
            tiktokHandle = viewModel.currentUser?.tiktokHandle ?? ""
        }
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView(viewModel: MainViewModel())
    }
}
