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
        VStack(spacing: 5) {
            HStack {
                
                Spacer()
                
                ProfilePhoto(url: user.profileImageURL, size: 175)
                
                Spacer()
                
                VStack {
                    
                    if (user.admin) {
                        Image(systemName: "crown")
                            .foregroundColor(.red)
                    }
                    
                    Text(user.username)
                        .font(.title)
                        .fontWeight(.bold)
                        .italic()
                        .multilineTextAlignment(.center)
                    
                    if (user.createdAt != nil) {
                        Text(user.createdAt.debugDescription)
                    }
                    
                    HStack {
                        Image(systemName: "message")
                        
                        if (user.commentCount ?? 0 == 1) {
                            Text("\(user.commentCount ?? 0) comment")
                        } else {
                            Text("\(user.commentCount ?? 0) comments")
                        }
                    }
                    .padding(.top, 1)
                }
                
                Spacer()
                
            }
            
            HStack {
                VStack (alignment: .leading) {
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
                                            .frame(width: 20, height: 20)
                                        
                                        Text("@\(user.twitterHandle!)")
                                            .foregroundColor(.secondary)
                                    }
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
                                        .frame(width: 20, height: 20)
                                    
                                    Text("@\(user.instagramHandle!)")
                                        .foregroundColor(.secondary)
                                }
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
                                        .frame(width: 20, height: 20)
                                    
                                    Text("@\(user.tiktokHandle!)")
                                        .foregroundColor(.secondary)
                                    
                                }
                            }
                        }
                    }
                }
                
                if (user.bio != "" && user.bio != nil) {
                    
                    Divider()
                        .frame(height: 80)
                        .padding()
                    
                    Text(user.bio ?? "")
                        .padding()
                        .multilineTextAlignment(.leading)
                }
            }
            
            .padding(.horizontal, 20)
            .padding(.top)
        }
    }
}

struct ProfilePopover_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePopover(user: User(id: "aisjdfiuewoijf", username: "poofy", bio: "hello world how are ya doin on this fine evening?", twitterHandle: "@poofy", instagramHandle: "@poofy", tiktokHandle: "@poofy"))
    }
}
