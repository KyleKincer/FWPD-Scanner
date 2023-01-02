//
//  ProfilePopover.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/22/22.
//

import SwiftUI

struct ProfilePopover: View {
    let user: User
    var body: some View {
        VStack() {
            HStack {
                VStack {
                    if (user.admin) {
                        Image(systemName: "crown")
                            .foregroundColor(.red)
                    }
                    
                    ProfilePhoto(url: user.profileImageURL, size: 150)
                    
                }
                
                VStack {
                    Text(user.username)
                        .font(.title2)
                        .fontWeight(.bold)
                        .italic()
                        .multilineTextAlignment(.center)
                    
                    if (user.bio != "" && user.bio != nil) {
                        Text(user.bio ?? "")
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .padding(.top)
            
            if (user.createdAt != nil) {
                Text(user.createdAt.debugDescription)
                    .padding()
            }
            
            HStack {
                Image(systemName: "message")
                
                if (user.commentCount ?? 0 == 1) {
                    Text("\(user.commentCount ?? 0) comment")
                } else {
                    Text("\(user.commentCount ?? 0) comments")
                }
            }
            .padding()
            
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
        }
        .padding(.horizontal)
    }
}

struct ProfilePopover_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePopover(user: User(id: "aisjdfiuewoijf", username: "poofy", bio: "hello world how are ya doin on this fine evening?", twitterHandle: "poofy", instagramHandle: "poofy", tiktokHandle: "poofy"))
    }
}
