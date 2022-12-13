//
//  WatchScannerModel.swift
//  WatchScanner Watch App
//
//  Created by Nick Molargik on 12/13/22.
//

import Foundation

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
