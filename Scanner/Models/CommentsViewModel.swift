//
//  CommentsViewModel.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/3/22.
//

import Foundation
import Firebase

class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    
    private var listener: ListenerRegistration?
    
    func startListening(activityId: String) {
        // create a reference to the "comments" collection within the activity's document
        let commentsRef = Firestore.firestore().collection("activities").document(activityId).collection("comments")
        
        // create a snapshot listener that listens for changes to the comments collection
        listener = commentsRef.addSnapshotListener { (querySnapshot, error) in
            // check for errors
            if let error = error {
                print("Error getting comments: \(error)")
                return
            }
            
            // update the comments property with the data from the snapshot
            self.updateComments(querySnapshot: querySnapshot)
        }
    }
    
    func submitComment(activityId: String, comment: String) {
        let newComment = Comment(user: "Kyle", text: comment)
        let commentsRef = Firestore.firestore().collection("activities").document(activityId).collection("comments")
        commentsRef.addDocument(data: newComment.toData())
    }
    
    func updateComments(querySnapshot: QuerySnapshot?) {
     // update the comments property with the data from the snapshot
//        objectWillChange.send()
        self.comments = querySnapshot?.documents.map({ Comment(document: $0) }) ?? []
        print("Comments: \(self.comments)")
    }

    
    func stopListening() {
        // stop listening for changes to the comments collection
        listener?.remove()
    }
}
