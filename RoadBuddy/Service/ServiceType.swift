//
//  ServiceType.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/29/24.
//

import Foundation

enum ServiceType {
    case geocoding(address: String)
    case address(search: String, currentLocatoin: Location)
    case direction(departureLat: Double, departureLon: Double, arrivalLat: Double, arrivalLon: Double)
    case transfer
    case icon(code: String)
    
    var urlPath: String {
        switch self {
        case .geocoding:
            return "http://3.25.65.146:8080/maps/geocoding"
        case .address:
            return "http://3.25.65.146:8080/maps/locations"
        case .direction:
            return "http://3.25.65.146:8080/maps/directions"
        case .icon:
            return "img/wn/"
        case .transfer:
            return "http://3.25.65.146:8080/subway/transfer"
        }
    }
    var components: URLComponents? {
        switch self {
        case .geocoding:
            return URLComponents(string: self.urlPath)
        case .address:
            return URLComponents(string: self.urlPath)
        case .direction:
            return URLComponents(string: self.urlPath)
        case .transfer:
            return URLComponents(string: self.urlPath)
        case .icon(code: let code):
            return URLComponents(string: "https://openweathermap.org/\(self.urlPath)\(code)@2x.png")
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .geocoding(let address):
            let queryItem = URLQueryItem(name: "query", value: String(address))
            return [queryItem]
        case .address(let search, let location):
            let searchItem = URLQueryItem(name: "query", value: search)
            let latitudeItem = URLQueryItem(name: "coordinate.latitude", value: String(location.lat))
            let longitudeItem = URLQueryItem(name: "coordinate.longitude", value: String(location.lng))
            return [searchItem, latitudeItem, longitudeItem]
        case .direction(let departureLat, let departureLon, let arrivalLat, let arrivalLon):
            let departureLatItem = URLQueryItem(name: "origin.latitude", value: String(departureLat))
            let departureLonItem = URLQueryItem(name: "origin.longitude", value: String(departureLon))
            let arrivalLatItem = URLQueryItem(name: "destination.latitude", value: String(arrivalLat))
            let darrivalLonItem = URLQueryItem(name: "destination.longitude", value: String(arrivalLon))
            return [departureLatItem, departureLonItem, arrivalLatItem, darrivalLonItem]
        default:
            return []
        }
    }
    
    var code: String {
        switch self {
        case .icon(code: let code):
            return code
        default:
            return ""
        }
    }

    func makeURL() -> URL? {
        var components = self.components
        components?.queryItems = self.queryItems
        return components?.url
    }
}
