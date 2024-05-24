//
//  ServiceType.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/29/24.
//

import Foundation

enum ServiceType {
    case geocoding(address: String)
    case address(search: String, currentLocatoin: Location?)
    case direction(departureLat: Double, departureLon: Double, arrivalLat: Double, arrivalLon: Double)
    case transfer
    case drive(departureLocation: Location, arrivalLocation: Location)
    
    var urlPath: String {
        let baseURL = "http://3.25.65.146:8080/"
        switch self {
        case .geocoding:
            return "\(baseURL)maps/geocoding"
        case .address:
            return "\(baseURL)maps/locations"
        case .direction:
            return "\(baseURL)maps/directions"
        case .transfer:
            return "\(baseURL)subway/transfer"
        case .drive:
            return "\(baseURL)maps/drive"
        }
    }
    
    var components: URLComponents? {
        return URLComponents(string: self.urlPath)
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .geocoding(let address):
            let queryItem = URLQueryItem(name: "query", value: String(address))
            return [queryItem]
        case .address(let search, let location):
            let searchItem = URLQueryItem(name: "query", value: search)
            if let location = location {
                let latitudeItem = URLQueryItem(name: "coordinate.latitude", value: String(location.lat))
                let longitudeItem = URLQueryItem(name: "coordinate.longitude", value: String(location.lng))
                return [searchItem, latitudeItem, longitudeItem]
            }
            return [searchItem]
        case .direction(let departureLat, let departureLon, let arrivalLat, let arrivalLon):
            let departureLatItem = URLQueryItem(name: "origin.latitude", value: String(departureLat))
            let departureLonItem = URLQueryItem(name: "origin.longitude", value: String(departureLon))
            let arrivalLatItem = URLQueryItem(name: "destination.latitude", value: String(arrivalLat))
            let darrivalLonItem = URLQueryItem(name: "destination.longitude", value: String(arrivalLon))
            return [departureLatItem, departureLonItem, arrivalLatItem, darrivalLonItem]
        case .drive(let departureLocation, let arrivalLocation):
            let departureLatItem = URLQueryItem(name: "start.latitude", value: String(departureLocation.lat))
            let departureLonItem = URLQueryItem(name: "start.longitude", value: String(departureLocation.lng))
            let arrivalLatItem = URLQueryItem(name: "end.latitude", value: String(arrivalLocation.lat))
            let arrivalLonItem = URLQueryItem(name: "end.longitude", value: String(arrivalLocation.lng))
            return [departureLatItem, departureLonItem, arrivalLatItem, arrivalLonItem]
        default:
            return []
        }
    }
    
    func makeURL() -> URL? {
        var components = self.components
        components?.queryItems = self.queryItems
        return components?.url
    }
}
