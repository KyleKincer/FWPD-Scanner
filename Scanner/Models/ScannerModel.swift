//
//  Model.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/13/22.
//

import Foundation
import Firebase


struct Scanner {
    struct Activity: Identifiable, Decodable, Equatable, Hashable, Encodable {
        var id: String
        let timestamp: String
        let nature: String
        let address: String
        let location: String
        var controlNumber: String
        let longitude: Double
        let latitude: Double
        var date: Date? = nil
        var distance: Double? = nil
        var bookmarked: Bool = false
        
        enum CodingKeys: String, CodingKey {
            // the API gives us control_number
            case controlNumber = "control_number"
            case id
            case timestamp
            case nature
            case address
            case location
            case longitude
            case latitude
            case date
            case distance
            case bookmarked
        }
        
        init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.id = try container.decode(String.self, forKey: .id)
                self.timestamp = try container.decode(String.self, forKey: .timestamp)
                self.nature = try container.decode(String.self, forKey: .nature)
                self.address = try container.decode(String.self, forKey: .address)
                self.location = try container.decode(String.self, forKey: .location)
                self.controlNumber = try container.decode(String.self, forKey: .controlNumber)
                self.longitude = try container.decode(Double.self, forKey: .longitude)
                self.latitude = try container.decode(Double.self, forKey: .latitude)
                self.date = try container.decode(Date.self, forKey: .date)
                self.distance = try container.decode(Double.self, forKey: .distance)
                self.bookmarked = try container.decode(Bool.self, forKey: .bookmarked)
            }
        
        init() {
                self.id = ""
                self.timestamp = ""
                self.nature = ""
                self.address = ""
                self.location = ""
                self.controlNumber = ""
                self.longitude = 0
                self.latitude = 0
                self.date = nil
                self.distance = nil
                self.bookmarked = false
            }
        
        init(id: String, timestamp: String, nature: String, address: String, location: String, controlNumber: String, longitude: Double, latitude: Double) {
                self.id = id
                self.timestamp = timestamp
                self.nature = nature
                self.address = address
                self.location = location
                self.controlNumber = controlNumber
                self.longitude = longitude
                self.latitude = latitude
                self.date = nil
                self.distance = nil
                self.bookmarked = false
            }
    }
    
    struct Nature: Identifiable, Decodable, Equatable {
        let id: String
        let name: String
    }
}

struct Timestamp: Decodable, Equatable, Hashable {
    let seconds: Int
    let nanoseconds: Int
    
    private enum CodingKeys: String, CodingKey {
        case seconds
        case nanoseconds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.seconds = try container.decode(Int.self, forKey: .seconds)
        self.nanoseconds = try container.decode(Int.self, forKey: .nanoseconds)
    }
    
    init(_ timestamp: Firebase.Timestamp) {
        self.seconds = Int(timestamp.seconds)
        self.nanoseconds = Int(timestamp.nanoseconds)
    }
    
    var firebaseTimestamp: Firebase.Timestamp {
        return Firebase.Timestamp(seconds: Int64(self.seconds), nanoseconds: Int32(self.nanoseconds))
    }
}

struct Comment: Identifiable, Decodable, Equatable, Hashable {
    static func == (lhs: Comment, rhs: Comment) -> Bool {
            return lhs.id == rhs.id &&
                   lhs.user == rhs.user &&
                   lhs.text == rhs.text &&
                   lhs.timestamp == rhs.timestamp
        }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.user)
            hasher.combine(self.text)
            hasher.combine(self.timestamp)
        }
    
    var id: String
    let user: String
    let text: String
    let timestamp: Timestamp

    private enum CodingKeys: String, CodingKey {
        case id
        case user
        case text
        case timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.user = try container.decode(String.self, forKey: .user)
        self.text = try container.decode(String.self, forKey: .text)
        self.timestamp = try container.decode(Timestamp.self, forKey: .timestamp)
    }

    init(document: QueryDocumentSnapshot) {
        print("Document: \(document)")
        self.id = document.documentID
        self.user = document.data()["user"] as! String
        self.text = document.data()["text"] as! String
        self.timestamp = Timestamp(document.data()["timestamp"] as! Firebase.Timestamp)
        print("Self: \(self)")
    }
    
    init(user: String, text: String) {
        self.id = ""
        self.user = user
        self.text = text
        self.timestamp = Timestamp(Firebase.Timestamp())
    }
    
    func toData() -> [String: Any] {
        return ["text": text,
                "user": user,
                "timestamp": timestamp.firebaseTimestamp]
    }
}


