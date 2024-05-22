//
//  AddressModel.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/8/24.
//

import Foundation

struct AddressModel: Codable, Hashable {
    let data: AddressData
}

struct AddressData: Codable, Hashable {
    var items: [Address]
}

struct Address: Codable, Hashable {
    var title: String
    let category: String
    let address: String
    let mapx: String
    let mapy: String
    var type: String?
    let geocoding: Geocoding
    
    var toSearchDataModel: SearchDataModel {
        return SearchDataModel(title: title, address: address)
    }
}

struct Geocoding: Codable, Hashable {
    let addresses: [GeocodingAddress]
}

struct GeocodingAddress: Codable, Hashable {
    let lat: String // lng
    let lng: String // lat
    let distance: Double
    var locatoin: Location {
        Location(lat: Double(lat)!, lng: Double(lng)!)
    }
    
    enum CodingKeys: String, CodingKey {
        case lat = "y"
        case lng = "x"
        case distance
    }
}

struct Location: Codable, Hashable {
    let lat: Double
    let lng: Double
}
