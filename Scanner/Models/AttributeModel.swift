//
//  Attribute.swift
//  Scanner
//

//  Created by Nick Molargik on 10/1/22.
//

import Foundation
import SwiftUI
import WidgetKit
import ActivityKit

struct LatestAttribute: ActivityAttributes {
    public typealias LatestStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        var activity: Scanner.Activity
    }
}

@available(iOS 16.1, *)
class LiveActivityHelper {
    var latestActivity: Activity<LatestAttribute>?
    
    func start() {
        // Check if live activities are enabled on this device
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled for Scanner on this device!")
            return
        }

        // Initialize the models
        let latestAttribute = LatestAttribute()
        let initialState = LatestAttribute.LatestStatus(activity: Scanner.Activity(id: "0", timestamp: "", nature: "Scanning for Activity", address: "", location: "", controlNumber: "", longitude: 0, latitude: 0))
        
        // Tell iOS that there is a new activity started
        do {
            latestActivity = try Activity<LatestAttribute>.request(
                attributes: latestAttribute,
                contentState: initialState,
                pushType: nil)
            
            guard let latestActivity else {
                print("Error: Could not initialize the live activity with ID: \(latestActivity?.id ?? "NO ID")")
                return
            }
            
            print("Live Activity Started with ID: \(latestActivity.id). Awaiting police activity.")
        } catch (let error) {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func update(activity: Scanner.Activity) {
        Task {
            let updatedLatest = LatestAttribute.LatestStatus(activity: activity)
            
            guard let latestActivity else {
                return
            }
            
            await latestActivity.update(using: updatedLatest)
        }
    }
    
    func end() {
        Task {
            let stoppingLatest = LatestAttribute.LatestStatus(activity: Scanner.Activity(id: "0", timestamp: "", nature: "Scanning Ended", address: "", location: "", controlNumber: "", longitude: 0, latitude: 0))
            
            guard let latestActivity else {
                return
            }
            
            await latestActivity.end(using: stoppingLatest, dismissalPolicy: .default)
        }
    }
}
