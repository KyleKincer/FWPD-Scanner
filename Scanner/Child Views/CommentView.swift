//
//  CommentView.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/7/22.
//

import SwiftUI

struct CommentView: View {
    let comment: Comment
    let formatter = RelativeDateTimeFormatter()
    
    var body: some View {
        HStack {
            if (comment.imageURL != ""){
                AsyncImage(url: URL(string: comment.imageURL)) { image in
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
                VStack(alignment: .leading) {
                    HStack {
                        Text(comment.userName)
                            .font(.headline)
                        Text("·")
                        
                        if (formatter.localizedString(for: comment.timestamp.firebaseTimestamp.dateValue(), relativeTo: Date()) == "0") {
                            Text("Just now")
                                .font(.caption)
                        }
                        
                        Text(formatter.localizedString(for: comment.timestamp.firebaseTimestamp.dateValue(), relativeTo: Date()))
                            .font(.caption)
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
        
        Divider()
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(comment: Comment(userId: "Admin", userName: "AdminKyle", text: "Howdy"))
    }
}
