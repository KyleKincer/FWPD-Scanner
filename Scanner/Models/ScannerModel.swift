//
//  Model.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/13/22.
//

import Foundation


struct Scanner {
    struct Activity: Identifiable, Decodable, Equatable, Hashable, Encodable {
        var id: Int
        let timestamp: String
        let nature: String
        let address: String
        let location: String
        let controlNumber: String
        let longitude: Double
        let latitude: Double
        var date: Date? = nil
        var distance: Double? = nil
        var bookmarked : Bool = false

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
            case distance
        }
    }
    
    struct Nature: Identifiable, Decodable, Equatable {
        let id: Int
        let name: String
    }
}



