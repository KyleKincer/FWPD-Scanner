//
//  SubscriptionManagerModel.swift
//  Scanner
//
//  Created by Nick Molargik on 11/20/22.
//

import Foundation
import FirebaseMessaging
import FirebaseFirestore

class SubscriptionManager {
    
    let db = Firestore.firestore() //Firestore Initialization
    
    // Notifications
    
    // Subscribe to topics
    func subscribeToNatures(natures: [String]) {
        for nature in natures {
            
            // Remove whitespace
            let topicName = nature.replacingOccurrences(of: " ", with: "")
            Messaging.messaging().subscribe(toTopic: topicName) { error in
                print("Subscribed to \(topicName) topic")
            }
        }
    }
    
    func removeNatures(natures: [String]) {
        for nature in natures {
            
            // Remove whitespace
            let topicName = nature.replacingOccurrences(of: " ", with: "")
            Messaging.messaging().unsubscribe(fromTopic: topicName) { error in
                print("Unsubscribed from \(topicName) topic")
            }
        }
    }
    
    func subscribeToAll() {
        Messaging.messaging().subscribe(toTopic: "ALL") { error in
            print("Subscribed to All topic")
        }
    }
    
    func unsubscribeFromAll() {
        Messaging.messaging().unsubscribe(fromTopic: "ALL") { error in
            print("Unbsubscribed from All topic")
        }
    }
    
    func subscribeLiveActivity(token: String, natures: [String]) {
        db.collection("LATokens").document(token).setData([
            "token": "\(token)",
            "natures": "\(natures)"
        ]) { err in
            if let err = err {
                print("X - Error writing document: \(err)")
            } else {
                print("G - Live Activity Updated")
            }
        }
    }
    
    func unsubscribeLiveActivity(token: String) {
        db.collection("LATokens").document(token).delete()
    }
}
