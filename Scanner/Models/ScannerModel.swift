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
        var comments: [Comment]?
        
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
                   lhs.text == rhs.text &&
                   lhs.timestamp == rhs.timestamp
        }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.text)
            hasher.combine(self.timestamp)
        }
    
    let id: String
    let text: String
    let timestamp: Timestamp
    let hidden: Bool
    let user: User

    private enum CodingKeys: String, CodingKey {
        case id
        case text
        case timestamp
        case hidden
        case user
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.timestamp = try container.decode(Timestamp.self, forKey: .timestamp)
        self.hidden = try container.decode(Bool.self, forKey: .hidden)
        self.user = try container.decode(User.self, forKey: .user)
    }

    init(document: QueryDocumentSnapshot, user: User) {
        self.id = document.documentID
        self.text = document.data()["text"] as! String
        self.timestamp = Timestamp(document.data()["timestamp"] as! Firebase.Timestamp)
        self.hidden = document.data()["hidden"] as? Bool ?? false
        self.user = user
    }
    
    init(id: String = UUID().uuidString, text: String, timestamp: Timestamp = Timestamp(Firebase.Timestamp()), hidden: Bool = false, user: User) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.hidden = hidden
        self.user = user
    }
    
    func toData() -> [String: Any] {
        return ["text": text,
                "userId": user.id,
                "timestamp": timestamp.firebaseTimestamp]
    }
}


struct User: Identifiable, Decodable {
    let id: String
    var username: String
    let admin: Bool
    var profileImageURL: URL?
    let commentCount: Int?
    let lastCommentAt: Timestamp?
    let createdAt: Timestamp?
    let twitterHandle: String?  // added this line
    let instagramHandle: String?  // added this line
    let facebookHandle: String?  // added this line
    let tiktokHandle: String?  // added this line
    
    init(id: String, username: String) {
        self.id = id
        self.username = username
        self.admin = false
        self.profileImageURL = nil
        self.commentCount = 0
        self.lastCommentAt = nil
        self.createdAt = nil
        self.twitterHandle = nil  // added this line
        self.instagramHandle = nil  // added this line
        self.facebookHandle = nil  // added this line
        self.tiktokHandle = nil  // added this line
    }
    
    init(id: String, username: String, profileImageURL: URL) {
        self.id = id
        self.username = username
        self.admin = false
        self.profileImageURL = URL(string: profileImageURL.description)
        self.commentCount = 0
        self.lastCommentAt = nil
        self.createdAt = nil
        self.twitterHandle = nil  // added this line
        self.instagramHandle = nil  // added this line
        self.facebookHandle = nil  // added this line
        self.tiktokHandle = nil  // added this line
    }
    
    init(document: DocumentSnapshot) {
        self.id = document.documentID
        self.username = (document.data()!["username"] as? String)!
        self.admin = document.data()?["admin"] as? Bool ?? false
        self.profileImageURL = URL(string: document.data()?["imageURL"] as! String)
        self.commentCount = document.data()?["commentCount"] as? Int
        self.lastCommentAt = document.data()?["lastCommentAt"] as? Timestamp
        self.createdAt = document.data()?["createdAt"] as? Timestamp
        self.twitterHandle = document.data()?["twitterHandle"] as? String  // added this line
        self.instagramHandle = document.data()?["instagramHandle"] as? String  // added this line
        self.facebookHandle = document.data()?["facebookHandle"] as? String  // added this line
        self.tiktokHandle = document.data()?["tiktokHandle"] as? String  // added this line
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case admin
        case profileImageURL
        case commentCount
        case lastCommentAt
        case createdAt
        case twitterHandle
        case instagramHandle
        case facebookHandle
        case tiktokHandle
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
        self.admin = try container.decode(Bool.self, forKey: .admin)
        self.profileImageURL = try container.decodeIfPresent(URL.self, forKey: .profileImageURL)
        self.commentCount = try container.decodeIfPresent(Int.self, forKey: .commentCount)
        self.lastCommentAt = try container.decodeIfPresent(Timestamp.self, forKey: .lastCommentAt)
        self.createdAt = try container.decodeIfPresent(Timestamp.self, forKey: .createdAt)
        self.twitterHandle = try container.decodeIfPresent(String.self, forKey: .twitterHandle)
        self.instagramHandle = try container.decodeIfPresent(String.self, forKey: .instagramHandle)
        self.facebookHandle = try container.decodeIfPresent(String.self, forKey: .facebookHandle)
        self.tiktokHandle = try container.decodeIfPresent(String.self, forKey: .tiktokHandle)
    }
}




