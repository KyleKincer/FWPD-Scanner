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
        var commentCount: Int?
        
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
            case commentCount
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
                self.commentCount = try container.decode(Int.self, forKey: .commentCount)
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
                self.commentCount = 0
            }
        
        init(id: String, timestamp: String, nature: String, address: String, location: String, controlNumber: String, longitude: Double, latitude: Double, commentCount: Int) {
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
                self.commentCount = commentCount
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
    
    init() {
        let timestamp = Firebase.Timestamp()
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
                   lhs.userId == rhs.userId &&
                   lhs.text == rhs.text &&
                   lhs.timestamp == rhs.timestamp
        }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.userId)
            hasher.combine(self.text)
            hasher.combine(self.timestamp)
        }
    
    let id: String
    let userId: String
    var userName: String
    let imageURL: String
    let text: String
    let timestamp: Timestamp
    let hidden: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case userId
        case userName
        case imageURL
        case text
        case timestamp
        case hidden
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
        self.text = try container.decode(String.self, forKey: .text)
        self.timestamp = try container.decode(Timestamp.self, forKey: .timestamp)
        self.hidden = try container.decode(Bool.self, forKey: .hidden)
    }

    init(document: QueryDocumentSnapshot) {
        print("Document: \(document)")
        self.id = document.documentID
        self.userId = document.data()["userId"] as! String
        self.userName = ""
        self.imageURL = ""
        self.text = document.data()["text"] as! String
        self.timestamp = Timestamp(document.data()["timestamp"] as! Firebase.Timestamp)
        self.hidden = document.data()["hidden"] as? Bool ?? false
    }
    
    init(id: String = UUID().uuidString, userId: String, userName: String, imageURL: String = "", text: String, timestamp: Timestamp = Timestamp(Firebase.Timestamp()), hidden: Bool = false) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.imageURL = imageURL
        self.text = text
        self.timestamp = timestamp
        self.hidden = hidden
    }
    
    func toData() -> [String: Any] {
        return ["text": text,
                "userId": userId,
                "timestamp": timestamp.firebaseTimestamp]
    }
}


