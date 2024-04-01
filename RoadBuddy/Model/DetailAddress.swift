//
//  DetailAddress.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/29/24.
//

import Foundation

struct DetailAddress: Hashable, Codable {
    let title: String
    let address: String
    let category: String
    let distance: Int // String? nope Int!
}
