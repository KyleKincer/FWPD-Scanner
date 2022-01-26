//
//  NetworkManager.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/16/22.
//

import Foundation
import CoreLocation

class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    
    // Do I need this???
    private override init() {}
    
    func getActivities(limit: Int = 100, dateFrom: Date? = nil, dateTo: Date? = nil, completed: @escaping (Result<[Scanner.Activity], ActError>) -> Void) {
        let formatter = DateFormatter()
        let dateFromStr: String
        let dateToStr: String
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Get dates if we have any
        if let dateFrom = dateFrom {
            dateFromStr = formatter.string(from: dateFrom)
        } else {
            dateFromStr = ""
        }
        if let dateTo = dateTo {
            dateToStr = formatter.string(from: dateTo)
        } else {
            dateToStr = ""
        }
        
        let url = URL(string: "\(Constants.ACTIVITY_URL)?limit=\(limit)&datefrom=\(dateFromStr)&dateto=\(dateToStr)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let _ =  error {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode([Scanner.Activity].self, from: data)
                completed(.success(decodedResponse))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        
        task.resume()
        
    }
    
    func getActivitiesWithinProximity(limit: Int = 100, location: CLLocation, radius: Double, completed: @escaping (Result<[Scanner.Activity], ActError>) -> Void) {
        
        let url = URL(string: "\(Constants.PROXIMITY_URL)?limit=\(limit)&longitude=\(location.coordinate.longitude)&latitude=\(location.coordinate.latitude)&radius=\(radius)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let _ =  error {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode([Scanner.Activity].self, from: data)
                completed(.success(decodedResponse))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        
        task.resume()
        
    }
}
