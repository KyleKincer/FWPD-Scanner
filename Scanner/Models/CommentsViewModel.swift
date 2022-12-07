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
    
    func submitComment(activityId: String, comment: String, userId: String, userName: String) -> Int {
        let newComment = Comment(userId: userId, userName: userName, text: comment)
        var newCommentCount = 1
        let activityRef = Firestore.firestore().collection("activities").document(activityId)
        
        // start a transaction
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            // get the document
            let document = try! transaction.getDocument(activityRef)
            
            // check if the document exists
            if let oldCommentCount = document.data()?["commentCount"] as? Int {
                // increment the comment count
                print("oldCommentCount: \(oldCommentCount)")
                newCommentCount = oldCommentCount + 1
            } else {
                
            }
            
            // update the document with the new comment count
            print("newCommentCount: \(newCommentCount)")
            transaction.updateData(["commentCount": newCommentCount], forDocument: document.reference)
            
            // return the new comment count
            return newCommentCount
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                // the transaction was successful, add the new comment
                let commentsRef = Firestore.firestore().collection("activities").document(activityId).collection("comments")
                commentsRef.addDocument(data: newComment.toData())
            }
        }
        print("newCommentCount: \(newCommentCount)")
        return newCommentCount
    }
    
    
    func updateComments(querySnapshot: QuerySnapshot?) {
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
                let userName = userDocument!.get("userName") as? String
                let text = commentDocument.data()["text"] as! String
                let comment = Comment(userId: userId, userName: userName ?? "Unknown User", text: text)
                
                // add the updated comment to the comments array
                self.comments.append(comment)
            }
        }
    }
    
    
    
    
    
    
    
    
    func stopListening() {
        // stop listening for changes to the comments collection
        listener?.remove()
    }
}
