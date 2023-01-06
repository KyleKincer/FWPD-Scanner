//
//  ProfilePopover.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/22/22.
//

import SwiftUI

struct ProfilePopover: View {
    @State private var showingAdmin = false
    let user: User
    var body: some View {
        VStack() {
            HStack {
                VStack {
                    if (user.admin) {
                        Image(systemName: "crown")
                            .foregroundColor(.red)
                            .onTapGesture {
                                showingAdmin = true
                            }
                    }
                    
                    ProfilePhoto(url: user.profileImageURL, size: 100)
                    
                }
                
                VStack {
                    Text(user.username)
                        .font(.title2)
                        .fontWeight(.bold)
                        .italic()
                        .multilineTextAlignment(.center)
                    
                    if (user.bio != "" && user.bio != nil) {
                        Text(user.bio ?? "")
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: false)
                    }
                }
            }
            .padding(.vertical)
            
            if (user.createdAt != "" && user.createdAt != nil) {
                Text("Member since " + user.createdAt!)
            }
            
            HStack {
                Image(systemName: "message")

                if (user.commentCount ?? 0 == 1) {
                    Text("\(user.commentCount ?? 0) comment contributed")
                } else {
                    Text("\(user.commentCount ?? 0) comments contributed")
                }
            }
            
            HStack (spacing: 20) {
                if (user.twitterHandle != "" || user.instagramHandle != "" || user.tiktokHandle != "") {
                    
                    if (user.twitterHandle != "" && user.twitterHandle != nil) {
                        HStack {
                            Button {
                                if let url = URL(string: "https://twitter.com/\(user.twitterHandle!)") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack {
                                    Image("twitter")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .shadow(radius: 2)
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    if (user.instagramHandle != "" && user.instagramHandle != nil) {
                        Button {
                            if let url = URL(string: "https://instagram.com/\(user.instagramHandle!)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image("instagram")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .shadow(radius: 2)
                            }
                            .foregroundColor(.pink)
                        }
                    }
                    
                    if (user.tiktokHandle != "" && user.tiktokHandle != nil) {
                        Button {
                            if let url = URL(string: "https://tiktok.com/@\(user.tiktokHandle!)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image("tiktok")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .shadow(radius: 2)
                            }
                            .foregroundColor(Color("ModeOpposite"))
                        }
                    }
                }
            }
            .padding()
            .alert("This user is designated as a community admin", isPresented: $showingAdmin) {
                        Button("OK", role: .cancel) { }
                    }
        }
        .padding(.horizontal, 5)
    }
}

struct ProfilePopover_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePopover(user: User(id: "aisjdfiuewoijf", username: "poofy", bio: "hello world how are ya doin on this fine evening? la la la la la la la la la", twitterHandle: "poofy", instagramHandle: "poofy", tiktokHandle: "poofy", admin: true, commentCount: 3))
    }
}
