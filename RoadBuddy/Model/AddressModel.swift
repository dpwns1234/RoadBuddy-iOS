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
    var items: [Address]
}

struct Address: Codable, Hashable {
    var title: String
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
