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
    private override init() {}
    
    func getActivities(page: Int, per_page: Int = 25, dateFrom: Date? = nil, dateTo: Date? = nil, natures: Set<Int>? = nil, location: CLLocation? = nil, radius: Double? = nil, completed: @escaping (Result<[Scanner.Activity], ActError>) -> Void) {
        let formatter = DateFormatter()
        let dateFromStr: String
        let dateToStr: String
        var latitudeStr = ""
        var longitudeStr = ""
        var radiusStr = ""
        var naturesStr = ""
        
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
        
        // Get the natures if we have any
        if let natures = natures {
            naturesStr = natures.sorted().map(String.init).joined(separator: ",")
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
        if let radius = radius {
            radiusStr = String(radius)
        }
        
        let url = URL(string: "\(Constants.ACTIVITY_URL)?page=\(page)&?per_page=\(per_page)&datefrom=\(dateFromStr)&dateto=\(dateToStr)&natures=\(naturesStr)&longitude=\(longitudeStr)&latitude=\(latitudeStr)&radius=\(radiusStr)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print(url)
        
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
    
    func getNatures(completed: @escaping (Result<[Scanner.Nature], ActError>) -> Void) {
        
        let url = URL(string: Constants.NATURE_URL)!
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
                let decodedResponse = try JSONDecoder().decode([Scanner.Nature].self, from: data)
                completed(.success(decodedResponse))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
}
