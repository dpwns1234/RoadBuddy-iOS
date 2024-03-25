//
//  DetailAddress.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/22/24.
//

import Foundation

protocol CellModelProtocol: Hashable, Codable {
    
}

struct DetailAddress: CellModelProtocol {
    let title: String
    let address: String
    let category: String
    let distance: Int // 또는 String ex. 12km
}
