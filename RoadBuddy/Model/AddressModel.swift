//
//  AddressModel.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/8/24.
//

import Foundation

struct AddressModel: Codable, Hashable {
    let data: LocationData
}

struct LocationData: Codable, Hashable {
    let items: [Address]
}

struct Address: Codable, Hashable {
    let title: String
    let category: String
    let address: String
    let mapx: String
    let mapy: String
    var type: String?
    var location: Location? = nil // TODO: 새로 location call 해야한다고 하니까 일단 nil
    
    var toSearchDataModel: SearchDataModel {
        return SearchDataModel(title: title, address: address)
    }
}

struct Location: Codable, Hashable {
    let lat: Double
    let lng: Double
}


//
//struct AddressModel: Decodable {
//    let results: [Address]
//}
//
//struct Address: Decodable, Hashable {
//    let detailAddress: String
//    let geometry: Geometry
//    let name: String
//    
//    var toSearchDataModel: SearchDataModel {
//        return SearchDataModel(title: name, address: detailAddress)
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case detailAddress = "formatted_address"
//        case geometry, name
//    }
//    
//    
//    struct Geometry: Decodable, Hashable {
//        let location: Location
//        let viewport: Viewport
//        
//        struct Viewport: Decodable, Hashable {
//            let northeast: Location
//            let southwest: Location
//        }
//    }
//}
//
//struct Location: Decodable, Hashable {
//    let lat: Double
//    let lng: Double
//}
