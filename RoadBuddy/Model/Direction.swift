//
//  Direction.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/25/24.
//

import Foundation

struct Direction: Decodable {
    let data: DirectionData
}

struct DirectionData: Decodable {
    let routes: Array<Route>
}

struct Route: Hashable, Decodable {
    let bounds: Bound?
    let legs: Array<Leg>
}

struct LegData:Hashable, Codable {
    let data: Leg
}

struct Leg: Hashable, Codable {
    let arrivalTime: InfoValue
    let departureTime: InfoValue
    let distance: InfoValue
    let duration: InfoValue
    let endAddress: String
    let endLocation: Location
    let startAddress: String
    let startLocation: Location
    let steps: Array<Step>
    
    enum CodingKeys: String, CodingKey {
        case arrivalTime = "arrival_time"
        case departureTime = "departure_time"
        case distance
        case duration
        case endAddress = "end_address"
        case endLocation = "end_location"
        case startAddress = "start_address"
        case startLocation = "start_location"
        case steps
    }
}

struct Step: Hashable, Codable {
    let distance: InfoValue
    let duration: InfoValue
    let endLocation: Location
    let startLocation: Location
    let polyline: Polyline
    let transitDetails: Transit?
    let travelMode: String
    let steps: [Step]?
    let transferPath: Array<Transfer>?
    let steepSlopes: [SteepSlope]?
    
    enum CodingKeys: String, CodingKey {
        case distance
        case duration
        case endLocation = "end_location"
        case startLocation = "start_location"
        case polyline
        case transitDetails = "transit_details"
        case travelMode = "travel_mode"
        case steps
        case transferPath = "transfer_path"
        case steepSlopes = "steep_slope"
    }
}

struct SteepSlope: Hashable, Codable {
    let shortAddress: String
    let latitude: Double
    let longitude: Double
}

struct Transfer: Hashable, Codable {
    let imgPath: String
    let mvContDtl: Array<String>
}

struct Transit: Hashable, Codable {
    let arrivalStop: LocationName
    let arrivalTime: InfoValue
    let departureStop: LocationName
    let departureTime: InfoValue
    let line: Line
    let numStops: String
    
    enum CodingKeys: String, CodingKey {
        case arrivalStop = "arrival_stop"
        case arrivalTime = "arrival_time"
        case departureStop = "departure_stop"
        case departureTime = "departure_time"
        case line
        case numStops = "num_stops"
    }
}

struct Line: Hashable, Codable {
    let color: String
    let name: String
    let shortName: String
    let textColor: String
    let vehicle: Vehicle
    
    enum CodingKeys: String, CodingKey {
        case color
        case name
        case shortName = "short_name"
        case textColor = "text_color"
        case vehicle
    }
    
}

struct Vehicle: Hashable, Codable {
    let icon: String
    let type: String
}

struct LocationName: Hashable, Codable {
    let location: Location
    let name: String
}

struct Polyline: Hashable, Codable {
    let points: String
}

struct Bound: Hashable, Codable {
    let northeast: Location
    let southwest: Location
}

struct InfoValue: Hashable, Codable {
    let text: String
    let value: Int
    let timeZone: String?
    
    enum CodingKeys: String, CodingKey {
        case text
        case value
        case timeZone = "time_zone"
    }
}
