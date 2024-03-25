//
//  SearchDataModel.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/22/24.
//

import Foundation

struct SearchDataModel: Hashable, Codable {
    let title: String
    var created: Date? = nil
    var address: String? = nil
    var category: String? = nil
    var distance: Int? = nil
}
