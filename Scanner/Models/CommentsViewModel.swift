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
    
    func submitComment(activityId: String, comment: String, userId: String) -> Int {
        let newComment = Comment(userId: userId, text: comment)
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
