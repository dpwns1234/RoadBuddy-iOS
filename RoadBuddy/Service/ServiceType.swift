//
//  ServiceType.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/29/24.
//

import Foundation

enum ServiceType {
    case geocoding(address: String)
    case address(search: String)
    case icon(code: String)
    
    var urlPath: String {
        switch self {
        case .geocoding:
            return "maps/geocoding/"
        case .address:
            return "https://maps.googleapis.com/maps/api/place/textsearch/json"
        case .icon:
            return "img/wn/"
        }
    }
    var components: URLComponents? {
        let baseURL = "localhost:8080/"
        switch self {
        case .geocoding:
            return URLComponents(string: "\(baseURL)\(self.urlPath)")
        case .address:
            return URLComponents(string: "\(self.urlPath)")
        case .icon(code: let code):
            return URLComponents(string: "https://openweathermap.org/\(self.urlPath)\(code)@2x.png")
        }
    }
    
    var queryItems: [URLQueryItem] {
        let APIKey = "AIzaSyDRBo-RB8kqyG00vSBSDzIh_OZOoNuO5QI"
        switch self {
        case .geocoding(let location):
            let queryItem = URLQueryItem(name: "address", value: String(location))
            return [queryItem]
        case .address(let search):
            let queryItem = URLQueryItem(name: "query", value: search)
            let languageItem = URLQueryItem(name: "language", value: "ko")
            let keyItem = URLQueryItem(name: "key", value: APIKey)
            return [queryItem, languageItem, keyItem]
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
