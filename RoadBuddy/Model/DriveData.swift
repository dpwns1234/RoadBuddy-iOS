//
//  Drive.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/22/24.
//

import Foundation

struct Drive: Decodable {
    let data: DriveData
}

struct DriveData: Decodable {
    let features: [Feature]
}

struct Feature: Decodable {
    let properties: Properties
}

struct Properties: Decodable {
    let totalDistance: Int?
    let totalTime: Int?
    let taxiFare: Int?
}
