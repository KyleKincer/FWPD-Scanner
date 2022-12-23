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
    
    var listener: ListenerRegistration?
    
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
    
    func submitComment(activityId: String, comment: String, user: User) {
        let newComment = Comment(text: comment, user: user)
        
        Firestore.firestore().collection("activities").document(activityId).updateData(["commentCount": FieldValue.increment(Double(1))])
        Firestore.firestore().collection("users").document(user.id).updateData(["commentCount": FieldValue.increment(Double(1)),
                                                                                "lastCommentAt" : Timestamp().firebaseTimestamp])
        
        let commentsRef = Firestore.firestore().collection("activities").document(activityId).collection("comments")
        commentsRef.addDocument(data: newComment.toData())
        
        commentsRef.parent?.updateData(["lastCommentAt" : Timestamp().firebaseTimestamp])
    }
    
    
    func updateComments(querySnapshot: QuerySnapshot?) {
        self.comments.removeAll()
        let usersRef = Firestore.firestore().collection("users")
        
        // loop through the comments and get the userName for each one
        for commentDocument in querySnapshot?.documents ?? [] {
            let userId = commentDocument.data()["userId"] as! String
            
            // Get the user document with the matching userId
            usersRef.document(userId).getDocument { (userDocument, error) in
                if let error = error {
                    // There was an error getting the user document
                    print("Error getting user with id '\(userId)': \(error)")
                    return
                }
                // update the comment's userName with the userName from the user document
                let user = User(document: userDocument!)
                let comment = Comment(document: commentDocument, user: user)
                
                // add the updated comment to the comments array
                self.comments.append(comment)
            }
        }
    }
    
    
    func deleteComment(comment: Comment, activityId: String) {
        let activityRef = Firestore.firestore().collection("activities").document(activityId)
        let commentsRef = activityRef.collection("comments")

        // Delete the comment
        commentsRef.document(comment.id).delete()
        activityRef.updateData(["commentCount": FieldValue.increment(Double(-1))])
        
        // Query to find the next most recent comment
        let query = commentsRef.order(by: "timestamp", descending: true).limit(to: 1)

        query.getDocuments { (querySnapshot, error) in
            if error != nil {
                // Handle the error
            } else {
                if querySnapshot?.documents.count == 0 {
                    // Delete the "lastCommentAt" field if there are no other comments
                    activityRef.updateData(["lastCommentAt": FieldValue.delete(),
                                            "commentCount": FieldValue.delete()])
                } else if let document = querySnapshot?.documents.first {
                    // Update the "lastCommentAt" field with the timestamp of the next most recent comment
                    activityRef.updateData(["lastCommentAt": document.get("timestamp")!])
                }
            }
        }
    }


    
    
    func hideComment(comment: Comment, activityId: String) {
        let commentsRef = Firestore.firestore().collection("activities").document(activityId).collection("comments").document(comment.id)
        // update the comment's hidden property in Firestore
        commentsRef.updateData(["hidden": !comment.hidden])
}
    
    
    func stopListening() {
        // stop listening for changes to the comments collection
        listener?.remove()
    }
}
