//
//  TravelType.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/15/24.
//

import Foundation

enum TravelType: String, CustomStringConvertible {
    case walking
    case bus
    case subway
    
    var description: String {
        switch self {
        case .walking:
            return "WALKING"
        case .bus:
            return "BUS"
        case .subway:
            return "SUBWAY"
        }
    }
}
