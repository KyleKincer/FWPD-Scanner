//
//  NetworkManager.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/16/22.
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
        let geohash = data["geohash"] as? String ?? ""
        let longitude = data["longitude"] as? Double ?? 0.0
        let nature = data["nature"] as? String ?? "UNKNOWN"
        let latitude = data["latitude"] as? Double ?? 0.0
        let activity = Scanner.Activity(id: id, timestamp: timestamp, nature: nature, address: address, location: location, controlNumber: controlNumber, longitude: longitude, latitude: latitude)
        return activity
    }
    
    //Get first 25 activities from Firestore
    func getFirstActivities(filterByDate: Bool, filterByLocation: Bool, filterByNature: Bool, dateFrom: Date? = nil, dateTo: Date? = nil, selectedNatures: [String], location: CLLocation? = nil, radius: Double? = nil) async throws -> [Scanner.Activity] {
        
        var activities = [Scanner.Activity]()
        let formatter = DateFormatter()
        let dateFromStr: String
        let dateToStr: String
        var latitudeStr = ""
        var longitudeStr = ""
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Get dates if we have any
        if let dateFrom = dateFrom, UserDefaults.standard.bool(forKey: "useDate") {
            dateFromStr = formatter.string(from: dateFrom)
        } else {
            dateFromStr = ""
        }
        if let dateTo = dateTo, UserDefaults.standard.bool(forKey: "useDate") {
            dateToStr = formatter.string(from: dateTo)
        } else {
            dateToStr = ""
        }
        if let latitude = location?.coordinate.latitude {
            latitudeStr = String(latitude)
        } else {
            latitudeStr = ""
        }
        if let longitude = location?.coordinate.longitude {
            longitudeStr = String(longitude)
        } else {
            longitudeStr = ""
        }

        print("Gathering Activities from Firestore")
        
        do {
            
            if (filterByLocation && filterByDate && filterByNature) {
                // Distance + DateRange + Natures
                print("Filtering by Location, Date, and Nature")
                
                
                
            } else if (filterByLocation && filterByDate) {
                // Distance + DateRange
                print("Filtering by Location and Date")
                
                
                
                
            } else if (filterByLocation && filterByNature) {
                // Distance + Natures
                print("Filtering by Location and Nature")
                
                
                
                
            } else if (filterByDate && filterByNature) {
                // DateRange + Natures
                print("Filtering by Date and Nature")
                
                let query = try await db.collection("activities")
                    .whereField("timestamp", isGreaterThanOrEqualTo: dateFromStr)
                    .whereField("timestamp", isLessThanOrEqualTo: dateToStr)
                    .whereField("nature", in: selectedNatures)
                    .order(by: "timestamp", descending: true)
                    .limit(to: 1000)
                    .getDocuments()
                self.lastDocument = query.documents.last
                for document in query.documents {
                    activities.append(self.makeActivity(document: document))
                }
                
            } else if (filterByLocation) {
                // Distance
                print("Filtering by Location")
                
                
                
                
            } else if (filterByDate) {
                // DateRange
                print("Filtering by Date")
                
                let query = try await db.collection("activities")
                    .whereField("timestamp", isGreaterThanOrEqualTo: dateFromStr)
                    .whereField("timestamp", isLessThanOrEqualTo: dateToStr)
                    .order(by: "timestamp", descending: true)
                    .limit(to: 25)
                    .getDocuments()
                self.lastDocument = query.documents.last
                for document in query.documents {
                    activities.append(self.makeActivity(document: document))
                }
                
            } else if (filterByNature) {
                // Natures
                print("Filtering by Nature")
                
                let query = try await db.collection("activities")
                    .whereField("nature", in: selectedNatures)
                    .order(by: "timestamp", descending: true)
                    .limit(to: 25)
                    .getDocuments()
                self.lastDocument = query.documents.last
                for document in query.documents {
                    activities.append(self.makeActivity(document: document))
                }
                
            } else {
                // No filters
                print("No Filters")
                
                let query = try await db.collection("activities")
                    .order(by: "timestamp", descending: true)
                    .limit(to: 25)
                    .getDocuments()
                self.lastDocument = query.documents.last
                for document in query.documents {
                    activities.append(self.makeActivity(document: document))
                }
            }
            
        } catch {
            print("Error getting activities: \(error.localizedDescription)")
        }
        
        
        //Bout damn time
        return activities
    }
    
    // Get 25 more activities from Firestore
    func getMoreActivities(filterByDate: Bool, filterByLocation: Bool, filterByNature: Bool, dateFrom: Date? = nil, dateTo: Date? = nil, selectedNatures: [String], location: CLLocation? = nil, radius: Double? = nil) async throws -> [Scanner.Activity] {
        
        var activities = [Scanner.Activity]()
        let formatter = DateFormatter()
        let dateFromStr: String
        let dateToStr: String
        var latitudeStr = ""
        var longitudeStr = ""
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Get dates if we have any
        if let dateFrom = dateFrom, UserDefaults.standard.bool(forKey: "useDate") {
            dateFromStr = formatter.string(from: dateFrom)
        } else {
            dateFromStr = ""
        }
        if let dateTo = dateTo, UserDefaults.standard.bool(forKey: "useDate") {
            dateToStr = formatter.string(from: dateTo)
        } else {
            dateToStr = ""
        }
        if let latitude = location?.coordinate.latitude {
            latitudeStr = String(latitude)
        } else {
            latitudeStr = ""
        }
        if let longitude = location?.coordinate.longitude {
            longitudeStr = String(longitude)
        } else {
            longitudeStr = ""
        }

        print("Getting more activities from Firestore")
        
        do {
            
            if (radius ?? 0.0 > 0.0 && dateFrom != nil && dateTo != nil && selectedNatures.count > 0) {
                // Distance + DateRange + Natures
                
                
                
                
            } else if (radius ?? 0.0 > 0.0 && dateFrom != nil && dateTo != nil) {
                // Distance + DateRange
                
                
                
                
            } else if (radius ?? 0.0 > 0.0 && selectedNatures.count > 0) {
                // Distance + Natures
                
                
                
                
            } else if (dateFrom != nil && dateTo != nil && selectedNatures.count > 0) {
                // DateRange + Natures
                let query = try await db.collection("activities")
                    .whereField("timestamp", isGreaterThanOrEqualTo: dateFromStr)
                    .whereField("timestamp", isLessThanOrEqualTo: dateToStr)
                    .whereField("nature", in: selectedNatures)
                    .order(by: "timestamp", descending: true)
                    .start(afterDocument: self.lastDocument!)
                    .limit(to: 25)
                    .getDocuments()
                self.lastDocument = query.documents.last
                for document in query.documents {
                    activities.append(self.makeActivity(document: document))
                }
                
            } else if (radius ?? 0.0 > 0.0) {
                // Distance
                
                
                
            } else if (dateFrom != nil && dateTo != nil) {
                // DateRange
                let query = try await db.collection("activities")
                    .whereField("timestamp", isGreaterThanOrEqualTo: dateFromStr)
                    .whereField("timestamp", isLessThanOrEqualTo: dateToStr)
                    .order(by: "timestamp", descending: true)
                    .start(afterDocument: self.lastDocument!)
                    .limit(to: 25)
                    .getDocuments()
                self.lastDocument = query.documents.last
                for document in query.documents {
                    activities.append(self.makeActivity(document: document))
                }
                
            } else if (selectedNatures.count > 0) {
                // Natures
                let query = try await db.collection("activities")
                    .whereField("nature", in: selectedNatures)
                    .order(by: "timestamp", descending: true)
                    .start(afterDocument: self.lastDocument!)
                    .limit(to: 25)
                    .getDocuments()
                self.lastDocument = query.documents.last
                for document in query.documents {
                    activities.append(self.makeActivity(document: document))
                }
                
            } else {
                // No filters
                let query = try await db.collection("activities")
                    .order(by: "timestamp", descending: true)
                    .start(afterDocument: self.lastDocument!)
                    .limit(to: 25)
                    .getDocuments()
                self.lastDocument = query.documents.last
                for document in query.documents {
                    activities.append(self.makeActivity(document: document))
                }
            }
            
        } catch {
            print("Error getting activities: \(error.localizedDescription)")
        }

        //Bout damn time
        return activities
    }
    
    // Get one single activity from Firestore
    func getActivity(controlNumber: String) async throws -> Scanner.Activity {
        let query = try await db.collection("activities")
            .whereField("control_number", isEqualTo: controlNumber)
            .order(by: "timestamp", descending: true)
            .getDocuments()
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
        let natureName = data["nature"] as? String ?? "UNKNOWN"
        let nature = Scanner.Nature(id: id, name: natureName)
        return nature
    }
    
    // Get natures from Firestore
    func getNatures() async throws -> [Scanner.Nature] {
        var natures : [Scanner.Nature] = []
        
        do {
            let query = try await db.collection("natures")
                .whereField("nature", isNotEqualTo: "")
                .order(by: "nature", descending: false)
                .getDocuments()
            
            for nature in query.documents {
                natures.append(self.makeNature(document: nature))
            }
        } catch {
            print("Error getting natures: \(error.localizedDescription)")
        }
        return natures
    }
}
