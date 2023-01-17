//
//  NetworkManager.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/16/22.
//

import Foundation
import CoreLocation
import Firebase
import GeoFire

class NetworkManager {
    var lastDocument : QueryDocumentSnapshot?
    let db = Firestore.firestore() //Firestore Initialization

    // Converts Firestore document into a single activity
    func makeActivity(document: QueryDocumentSnapshot) -> Scanner.Activity {
        let id = document.documentID
        let data = document.data()
        let location = data["location"] as? String ?? "Unknown"
        let address = data["address"] as? String ?? ""
        let timestamp = data["timestamp"] as? String ?? ""
        let controlNumber = data["control_number"] as? String ?? ""
        let longitude = data["longitude"] as? Double ?? 0.0
        let nature = data["nature"] as? String ?? "Unknown"
        let latitude = data["latitude"] as? Double ?? 0.0
        let commentCount = data["commentCount"] as? Int ?? 0
        let activity = Scanner.Activity(id: id, timestamp: timestamp, nature: nature, address: address, location: location, controlNumber: controlNumber, longitude: longitude, latitude: latitude, commentCount: commentCount)
        return activity
    }
    
    //Get first 25 activities from Firestore
    func getFirstActivities(filterByDate: Bool, filterByLocation: Bool, filterByNature: Bool, dateFrom: String, dateTo: String, selectedNatures: [String]?, location: CLLocation? = nil, radius: Double? = nil) async throws -> [Scanner.Activity] {
        var activities = [Scanner.Activity]()
        let selectedNatures = selectedNatures
        
        // Prepare location filters
        let distance = (radius ?? 0) / 0.621371 * 1000
        let center = location?.coordinate
        let queryBounds = GFUtils.queryBounds(forLocation: center ?? CLLocationCoordinate2D(latitude: 00.0, longitude: 00.0), withRadius: distance)
        
        // Prepare natures
        print("+ --- Gathering Activities from Firestore")
        
        do {
            if (filterByLocation) {
                // Distance
                print("F -- Filtering by Location")
                
                let queries = queryBounds.map { bound -> Query in
                    return db.collection("activities")
                        .order(by: "geohash")
                        .limit(to: 400)
                        .start(at: [bound.startValue])
                        .end(at: [bound.endValue])
                }
                
                var matchingDocs = [QueryDocumentSnapshot]()
                
                for queryStatement in queries {
                    let query = try await queryStatement.getDocuments(source: .server)
                    
                    for document in query.documents {
                        let lat = document.data()["latitude"] as? Double ?? 0
                        let lng = document.data()["longitude"] as? Double ?? 0
                        let coordinates = CLLocation(latitude: lat, longitude: lng)
                        let centerPoint = CLLocation(latitude: center!.latitude , longitude: center!.longitude )

                        // We have to filter out a few false positives due to GeoHash accuracy, but
                        // most will match
                        let eventDistance = GFUtils.distance(from: centerPoint, to: coordinates)
                        if eventDistance <= distance {
                            matchingDocs.append(document)
                        }
                    }
                    
                    if (matchingDocs.count > 0) {
                        self.lastDocument = matchingDocs.last
                    }
                    
                    for document in matchingDocs {
                        activities.append(self.makeActivity(document: document))
                    }
                    matchingDocs = []
                }
                activities = activities.sorted(by: { $0.timestamp > $1.timestamp })
                
            } else if (filterByDate) {
                // DateRange
                print("F -- Filtering by Date")
                
                let query = try await db.collection("activities")
                    .whereField("timestamp", isGreaterThanOrEqualTo: dateFrom)
                    .whereField("timestamp", isLessThanOrEqualTo: dateTo)
                    .order(by: "timestamp", descending: true)
                    .limit(to: 25)
                    .getDocuments(source: .server)
                if (query.documents.count > 0) {
                    self.lastDocument = query.documents.last
                }
                for document in query.documents {
                    activities.append(self.makeActivity(document: document))
                }
                
                activities = activities.sorted(by: { $0.timestamp > $1.timestamp })
                
            } else if (filterByNature && selectedNatures!.count > 1 && selectedNatures!.count < 11) {
                // Natures
                print("F -- Filtering by Nature")
                var selected = selectedNatures
                
                selected?.removeAll(where: {$0 == ""})
                
                let query = try await db.collection("activities")
                    .whereField("nature", in: selected!)
                    .order(by: "timestamp", descending: true)
                    .limit(to: 25)
                    .getDocuments(source: .server)
                if (query.documents.count > 0) {
                    self.lastDocument = query.documents.last
                }
                for document in query.documents {
                    activities.append(self.makeActivity(document: document))
                }
                
                activities = activities.sorted(by: { $0.timestamp > $1.timestamp })
                
            } else {
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
                
                activities = activities.sorted(by: { $0.timestamp > $1.timestamp })
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
                var selected = selectedNatures
                
                selected?.removeAll(where: {$0 == ""})
                
                let query = try await db.collection("activities")
                    .whereField("nature", in: selected!)
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
    func getActivity(controlNumber: String, isFire: Bool) async throws -> Scanner.Activity {
        if (isFire) {
            let query = try await db.collection("fires")
                .whereField("control_number", isEqualTo: controlNumber)
                .order(by: "timestamp", descending: true)
                .getDocuments(source: .server)
            
                let activity = self.makeFire(document: query.documents.first!)
            
                return activity
            
        } else {
            let query = try await db.collection("activities")
                .whereField("control_number", isEqualTo: controlNumber)
                .order(by: "timestamp", descending: true)
                .getDocuments(source: .server)
            
            let activity = self.makeActivity(document: query.documents.first!)
            return activity
        }
        
        
    }
    
    func getAllActivities() async throws -> [Scanner.Activity] {
        var activities : [Scanner.Activity] = []
        
        let query = try await db.collection("activities")
            .order(by: "timestamp", descending: true)
            .limit(to: 1500)
            .getDocuments(source: .server)
        
        let documents = query.documents
        
        for doc in documents {
            let activity = self.makeActivity(document: doc)
            activities.append(activity)
        }
        
        return activities
    }
    
    // Get a defined array of activites from their control numbers
    func getActivitySet(controlNumbers: [String], isFire: Bool) async throws -> [Scanner.Activity] {
        var activities : [Scanner.Activity] = []
        
        for controlNum in controlNumbers {
            do {
                try await activities.append(self.getActivity(controlNumber: controlNum, isFire: isFire))
            }
        }
        return activities.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    func getRecentlyCommentedActivities(getFires: Bool) async throws -> [Scanner.Activity] {
        var activities = [Scanner.Activity]()
        
        do {
            if (getFires) {
                let db = Firestore.firestore()
                let firesRef = db.collection("fires")
                let fireQuery = firesRef.order(by: "lastCommentAt", descending: true).limit(to: 100)
                let fires = try await fireQuery.getDocuments(source: .server)
                for document in fires.documents {
                    let data = document.data()
                    let commentCount = data["commentCount"] as? Int ?? 0
                    
                    if (commentCount > 0) {
                        let activity = self.makeFire(document: document)
                        activities.append(activity)
                    }
                }
            } else {
                
                let activitiesRef = db.collection("activities")
                let query = activitiesRef.order(by: "lastCommentAt", descending: true).limit(to: 100)
                let results = try await query.getDocuments(source: .server)
                for document in results.documents {
                    let data = document.data()
                    let commentCount = data["commentCount"] as? Int ?? 0
                    
                    if (commentCount > 0) {
                        let activity = self.makeActivity(document: document)
                        activities.append(activity)
                    }
                }
            }
        }
        return activities
    }
    
    // Converts Firestore fire document into a single fire
    func makeFire(document: QueryDocumentSnapshot) -> Scanner.Activity {
        let id = document.documentID
        let data = document.data()
        let address = data["address"] as? String ?? ""
        let timestamp = data["timestamp"] as? String ?? ""
        let controlNumber = data["control_number"] as? String ?? ""
        let nature = data["nature"] as? String ?? "Unknown"
        let commentCount = data["commentCount"] as? Int ?? 0
        let fire = Scanner.Activity(id: id, timestamp: timestamp, nature: nature, address: address, controlNumber: controlNumber, commentcount: commentCount, isFire: "true")
        
        return fire
    }
    
    func getFirstFires(filterByDate: Bool, dateFrom: String, dateTo: String) async throws -> [Scanner.Activity] {
        var fires = [Scanner.Activity]()

        // Prepare natures
        print("+ --- Gathering Fires from Firestore")
        
        do {
            if (filterByDate) {
                // DateRange
                print("F -- Filtering by Date")
                
                let query = try await db.collection("activities")
                    .whereField("timestamp", isGreaterThanOrEqualTo: dateFrom)
                    .whereField("timestamp", isLessThanOrEqualTo: dateTo)
                    .whereField("isFire", isEqualTo: "true")
                    .order(by: "timestamp", descending: true)
                    .limit(to: 25)
                    .getDocuments(source: .server)
                if (query.documents.count > 0) {
                    self.lastDocument = query.documents.last
                }
                for document in query.documents {
                    fires.append(self.makeFire(document: document))
                }
                
                fires = fires.sorted(by: { $0.timestamp > $1.timestamp })
                
            } else {
                // No filters
                print("F -- No Filters")
                
                let query = try await db.collection("fires")
                    .order(by: "timestamp", descending: true)
                    .limit(to: 25)
                    .getDocuments(source: .server)
                if (query.documents.count > 0) {
                    self.lastDocument = query.documents.last
                }
                for document in query.documents {
                    fires.append(self.makeFire(document: document))
                }
                
                fires = fires.sorted(by: { $0.timestamp > $1.timestamp })
            }
            
        } catch {
            print("X - Error getting fires: \(error.localizedDescription)")
        }
        
        //Bout damn time
        return fires
    }
    
    
    
    func getMoreFires(filterByDate: Bool, dateFrom: String, dateTo: String) async throws -> [Scanner.Activity] {
        
        var fires = [Scanner.Activity]()
        print("+ --- Getting more Fires from Firestore")
        
        do {
            if (filterByDate) {
                // DateRange
                print("F -- Filtering by Date")
                
                let query = try await db.collection("fires")
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
                    fires.append(self.makeFire(document: document))
                }
                
            } else {
                // No filters
                print("F -- No Filters")
                
                let query = try await db.collection("fires")
                    .order(by: "timestamp", descending: true)
                    .start(afterDocument: self.lastDocument!)
                    .limit(to: 25)
                    .getDocuments(source: .server)
                if (query.documents.count > 0) {
                    self.lastDocument = query.documents.last
                }
                for document in query.documents {
                    fires.append(self.makeFire(document: document))
                }
            }
            
        } catch {
            print("X - Error getting fires: \(error.localizedDescription)")
        }

        //Bout damn time
        return fires
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
                let nature = self.makeNature(document: nature)
                if (nature.name != "") {
                    natures.append(nature)
                }
            }
        } catch {
            print("X - Error getting natures: \(error.localizedDescription)")
        }
        return natures
    }
}
