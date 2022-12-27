//
//  CommentView.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/7/22.
//

import SwiftUI

struct CommentView: View {
    let comment: Comment
    let admin: Bool
    let formatter = RelativeDateTimeFormatter()
    
    @State private var showingProfile = false
    
    var body: some View {
        HStack {
            Button {
                showingProfile = true
            } label: {
                if ((comment.user.profileImageURL) != nil){
                    AsyncImage(url: comment.user.profileImageURL) { image in
                            image
                                .resizable()
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                        } placeholder: {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.gray)
                        }
                        
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.gray)
                    }
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(comment.user.username)
                        .font(.headline)
                    if (comment.user.admin) {
                        Image(systemName: "crown")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                    Text("·")
                    
                    if (formatter.localizedString(for: comment.timestamp.firebaseTimestamp.dateValue(), relativeTo: Date()) == formatter.localizedString(for: Date.now, relativeTo: Date())) {
                        Text("Just now")
                            .font(.caption)
                    } else {
                        
                        Text(formatter.localizedString(for: comment.timestamp.firebaseTimestamp.dateValue(), relativeTo: Date()))
                            .font(.caption)
                    }
                }
                .foregroundColor(.gray)
                
                if !comment.hidden {
                    Text(comment.text)
                } else {
                    Text("Comment hidden")
                        .italic()
                }
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingProfile) {
            if #available(iOS 16.0, *) {
                ProfilePopover(user: comment.user)
                    .presentationDetents([.medium, .large])
            } else {
                ProfilePopover(user: comment.user)
            }
        }
    
        Divider()
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(comment: Comment(text: "Howdy!!!!!", user: User(id: "1", username: "poofy")), admin: true)
    }
}
