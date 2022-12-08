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
    
    func submitComment(activityId: String, comment: String, userId: String, userName: String) {
        let newComment = Comment(userId: userId, userName: userName, text: comment)
        
        Firestore.firestore().collection("activities").document(activityId).updateData(["commentCount": FieldValue.increment(Double(1))])
        
        let commentsRef = Firestore.firestore().collection("activities").document(activityId).collection("comments")
        commentsRef.addDocument(data: newComment.toData())
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
                let userName = userDocument!.get("username") as? String
                let text = commentDocument.data()["text"] as! String
                let timestamp = commentDocument.data()["timestamp"] as! Firebase.Timestamp
                let id = commentDocument.documentID
                let comment = Comment(id: id, userId: userId, userName: userName ?? "Unknown User", text: text, timestamp: Timestamp(timestamp))
                
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
