//
//  ServiceType.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/29/24.
//

import Foundation

enum ServiceType {
    case geocoding(address: String)
    case detail(input: String)
    case icon(code: String)
    
    var urlPath: String {
        switch self {
        case .geocoding:
            return "maps/geocoding/"
        case .detail:
            return "maps/locations/"
        case .icon:
            return "img/wn/"
        }
    }
    var components: URLComponents? {
        let baseURL = "localhost:8080/"
        switch self {
        case .geocoding:
            return URLComponents(string: "\(baseURL)\(self.urlPath)")
        case .detail:
            return URLComponents(string: "\(baseURL)\(self.urlPath)")
        case .icon(code: let code):
            return URLComponents(string: "https://openweathermap.org/\(self.urlPath)\(code)@2x.png")
        }
    }
    
    var queryItems: [URLQueryItem] {
        let apiKey = "9025fdb78bf735a4b7287e0dcc03e4fd"
        switch self {
        case .geocoding(let address):
            let queryItem = URLQueryItem(name: "address", value: String(address))
            return [queryItem]
        case .detail(let input):
            let queryItem = URLQueryItem(name: "input", value: String(input))
            return [queryItem]
//            return [latQueryItem, lonQueryItem, apiKeyQueryItem]
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
