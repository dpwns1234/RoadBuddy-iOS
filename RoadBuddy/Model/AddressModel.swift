//
//  AddressModel.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/8/24.
//

import Foundation

struct AddressModel: Decodable {
    let results: [Address]
}

struct Address: Decodable, Hashable {
    let detailAddress: String
    let geometry: Geometry
    let name: String
    
    var toSearchDataModel: SearchDataModel {
        return SearchDataModel(title: name, address: detailAddress)
    }
    
    enum CodingKeys: String, CodingKey {
        case detailAddress = "formatted_address"
        case geometry, name
    }
    
    
    struct Geometry: Decodable, Hashable {
        let location: Location
        let viewport: Viewport
        
        struct Viewport: Decodable, Hashable {
            let northeast: Location
            let southwest: Location
        }
    }
}

struct Location: Decodable, Hashable {
    let lat: Double
    let lng: Double
}
