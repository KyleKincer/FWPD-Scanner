//
//  CommentView.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/7/22.
//

import SwiftUI

struct CommentView: View {
    let comment: Comment
    var body: some View {
        if !comment.hidden {
            HStack {
                Image(systemName: "person.circle")
                    .foregroundColor(.gray)
                VStack(alignment: .leading) {
                    HStack {
                        Text(comment.userName)
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("·")
                        Text(comment.timestamp.firebaseTimestamp.dateValue().formatted())
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Text(comment.text)
                }
            }
            .padding(.vertical, 4)
            
        }
    }
}

//struct CommentView_Previews: PreviewProvider {
//    static var previews: some View {
//        CommentView()
//    }
//}
