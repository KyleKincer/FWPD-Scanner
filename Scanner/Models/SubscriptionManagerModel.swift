//
//  SubscriptionManagerModel.swift
//  Scanner
//
//  Created by Nick Molargik on 11/20/22.
//

import Foundation
import FirebaseMessaging

class SubscriptionManager {
    // Notifications
    
    // Subscribe to topics
    func subscribeToNatures(natures: [String]) {
        for nature in natures {

            Messaging.messaging().subscribe(toTopic: nature) { error in
                print("Subscribed to \(nature) topic")
            }
        }
    }
    
    func removeNatures(natures: [String]) {
        for nature in natures {
            Messaging.messaging().unsubscribe(fromTopic: nature) { error in
                print("Unsubscribed from \(nature) topic")
            }
        }
    }
    
}
