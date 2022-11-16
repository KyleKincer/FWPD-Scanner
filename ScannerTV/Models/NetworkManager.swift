//
//  NetworkManager.swift
//  ScannerTV
//
//  Created by Nick Molargik on 11/15/22.
//

import Foundation
import CoreLocation
import FirebaseFirestore

class NetworkManager {
    var lastDocument : QueryDocumentSnapshot?
    let db = Firestore.firestore() //Firestore Initialization

    // Converts Firestore document into a single activity
    func makeActivity(document: QueryDocumentSnapshot) -> Scanner.Activity {
        let id = document.documentID
        let data = document.data()
        let location = data["location"] as? String ?? "UNKNOWN"
        let address = data["address"] as? String ?? ""
        let timestamp = data["timestamp"] as? String ?? ""
        let controlNumber = data["control_number"] as? String ?? ""
        let longitude = data["longitude"] as? Double ?? 0.0
        let nature = data["nature"] as? String ?? "UNKNOWN"
        let latitude = data["latitude"] as? Double ?? 0.0
        let activity = Scanner.Activity(id: id, timestamp: timestamp, nature: nature, address: address, location: location, controlNumber: controlNumber, longitude: longitude, latitude: latitude)
        return activity
    }
    
    //Get first 25 activities from Firestore
    func getFirstActivities(filterByDate: Bool, filterByLocation: Bool, filterByNature: Bool, dateFrom: String, dateTo: String, selectedNatures: [String]?, location: CLLocation? = nil, radius: Double? = nil) async throws -> [Scanner.Activity] {
        var activities = [Scanner.Activity]()
        
        // Prepare natures
        print("+ --- Gathering Activities from Firestore")
        
        do {

            // No filters
            print("F -- No Filters")
            
            let query = try await db.collection("activities")
                .order(by: "timestamp", descending: true)
                .limit(to: 25)
                .getDocuments(source: .server)
            if (query.documents.count > 0) {
                self.lastDocument = query.documents.last
            }
            for document in query.documents {
                activities.append(self.makeActivity(document: document))
            }
        } catch {
            print("X - Error getting activities: \(error.localizedDescription)")
        }
        
        //Bout damn time
        return activities
    }
    
    // Get 25 more activities from Firestore
    func getMoreActivities(filterByDate: Bool, filterByLocation: Bool, filterByNature: Bool, dateFrom: String, dateTo: String, selectedNatures: [String]? = nil, location: CLLocation? = nil, radius: Double? = nil) async throws -> [Scanner.Activity] {
        
        var activities = [Scanner.Activity]()
        let selectedNatures = selectedNatures

        print("+ --- Getting more activities from Firestore")
        
        do {
            if (filterByLocation) {
                // Distance
                print("F -- Filtering by Location / Rejected")

            } else if (filterByDate) {
                // DateRange
                print("F -- Filtering by Date")
                
                let query = try await db.collection("activities")
                    .whereField("timestamp", isGreaterThanOrEqualTo: dateFrom)
                    .whereField("timestamp", isLessThanOrEqualTo: dateTo)
                    .order(by: "timestamp", descending: true)
                    .start(afterDocument: self.lastDocument!)
                    .limit(to: 25)
                    .getDocuments(source: .server)
                if (query.documents.count > 0) {
                    self.lastDocument = query.documents.last
                }
                for document in query.documents {
                    activities.append(self.makeActivity(document: document))
                }
                
            } else if (filterByNature && selectedNatures!.count > 1 && selectedNatures!.count < 11) {
                // Natures
                print("F -- Filtering By Nature")
                
                let query = try await db.collection("activities")
                    .whereField("nature", in: selectedNatures!)
                    .order(by: "timestamp", descending: true)
                    .start(afterDocument: self.lastDocument!)
                    .limit(to: 25)
                    .getDocuments(source: .server)
                if (query.documents.count > 0) {
                    self.lastDocument = query.documents.last
                }
                for document in query.documents {
                    activities.append(self.makeActivity(document: document))
                }
                
            } else {
                // No filters
                print("F -- No Filters")
                
                let query = try await db.collection("activities")
                    .order(by: "timestamp", descending: true)
                    .start(afterDocument: self.lastDocument!)
                    .limit(to: 25)
                    .getDocuments(source: .server)
                if (query.documents.count > 0) {
                    self.lastDocument = query.documents.last
                }
                for document in query.documents {
                    activities.append(self.makeActivity(document: document))
                }
            }
            
        } catch {
            print("X - Error getting activities: \(error.localizedDescription)")
        }

        //Bout damn time
        return activities
    }
    
    // Get one single activity from Firestore
    func getActivity(controlNumber: String) async throws -> Scanner.Activity {
        let query = try await db.collection("activities")
            .whereField("control_number", isEqualTo: controlNumber)
            .order(by: "timestamp", descending: true)
            .getDocuments(source: .server)
        let activity = self.makeActivity(document: query.documents.first!)
        
        return activity
    }
    
    // Get a defined array of activites from their control numbers
    func getActivitySet(controlNumbers: [String]) async throws -> [Scanner.Activity] {
        var activities : [Scanner.Activity] = []
        
        for controlNum in controlNumbers {
            do {
                try await activities.append(self.getActivity(controlNumber: controlNum))
            }
        }
        
        return activities.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    func makeNature(document: QueryDocumentSnapshot) -> Scanner.Nature {
        let id = document.documentID
        let data = document.data()
        let natureName = data["nature"] as? String ?? ""
        let nature = Scanner.Nature(id: id, name: natureName)
        return nature
    }
    
    // Get natures from Firestore
    func getNatures() async throws -> [Scanner.Nature] {
        var natures : [Scanner.Nature] = []
        
        do {
            let query = try await db.collection("natures")
                .order(by: "nature", descending: false)
                .getDocuments(source: .server)
            
            for nature in query.documents {
                natures.append(self.makeNature(document: nature))
            }
        } catch {
            print("X - Error getting natures: \(error.localizedDescription)")
        }
        return natures
    }
}

