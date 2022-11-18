//
//  NetworkManagerWatch.swift
//  WatchScanner Watch App
//
//  Created by Nick Molargik on 11/15/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class NetworkManager {
    var session = URLSession.shared
    var pageToken = String()
    
    func getActivities() async throws -> [Scanner.Activity] {
        var request = URLRequest(url: URL(string: "https://firestore.googleapis.com/v1beta1/projects/fwpd-api/databases/(default)/documents/activities?orderBy=timestamp%20desc&pageSize=25&access_token=4ae4feb38730ff8a27885dfcde81d892c66d544b&key=[AIzaSyBP_YYDmOcVBt2KqtFtig0eFoKmo29psHk]%20HTTP/1.1")!,timeoutInterval: Double.infinity)
        request.addValue("application/json ", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
        do {
            let decoder = JSONDecoder()
            decoder.dataDecodingStrategy = .base64
        
            let decoded = try decoder.decode(Response.self, from: data)
            self.pageToken = decoded.nextPageToken
            let documents = decoded.documents
            var activities = [Scanner.Activity]()
            for document in documents {
                let activity = Scanner.Activity(id: document.name.replacingOccurrences(of: "rojects/fwpd-api/databases/(default)/documents/activities/", with: ""), timestamp: document.fields.timestamp.stringValue, nature: document.fields
                    .nature.stringValue, address: document.fields.address.stringValue, location: document.fields.location.stringValue, controlNumber: document.fields.control_number.stringValue, longitude: document.fields.longitude.doubleValue, latitude: document.fields.latitude.doubleValue)
                
                activities.append(activity)
            }
            return activities
        }
    }
    
    func getMoreActivities() async throws -> [Scanner.Activity] {
        let url = "https://firestore.googleapis.com/v1beta1/projects/fwpd-api/databases/(default)/documents/activities?orderBy=timestamp%20desc&pageSize=25&pageToken=\(self.pageToken)&access_token=4ae4feb38730ff8a27885dfcde81d892c66d544b&key=[AIzaSyBP_YYDmOcVBt2KqtFtig0eFoKmo29psHk]"
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)
        request.addValue("application/json ", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError ("Error while fetching data") }
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(Response.self, from: data)
            self.pageToken = decoded.nextPageToken

            let documents = decoded.documents
            var activities = [Scanner.Activity]()
            for document in documents {
                let activity = Scanner.Activity(id: document.name.replacingOccurrences(of: "rojects/fwpd-api/databases/(default)/documents/activities/", with: ""), timestamp: document.fields.timestamp.stringValue, nature: document.fields
                    .nature.stringValue, address: document.fields.address.stringValue, location: document.fields.location.stringValue, controlNumber: document.fields.control_number.stringValue, longitude: document.fields.longitude.doubleValue, latitude: document.fields.latitude.doubleValue)
                
                activities.append(activity)
            }
            return activities
        }
    }
}
