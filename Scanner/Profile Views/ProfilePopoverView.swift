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
            // Photo
            ProfilePhoto(url: user.profileImageURL, size: 175)
            
            // Username
            Text(user.username)
                .font(.title)
                .fontWeight(.bold)
                .italic()
                .multilineTextAlignment(.center)
            
            // Date joined
            
            
            // Comments
            if let commentCount = user.commentCount {
                HStack {
                    Image(systemName: "message")
                    Text("\(commentCount) \(commentCount > 1 ? "comments" : "comment")")
                }
            }
        }
    }
}

struct ProfilePopover_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePopover(user: User(id: "aisjdfiuewoijf", username: "poofy", profileImageURL: URL(string: "https://lh3.googleusercontent.com/a/AEdFTp4Uf7Cb6dGGzHtLhGuCgApMQdG5UIaNndcDBh2fFw=s96-c")!))
    }
}
