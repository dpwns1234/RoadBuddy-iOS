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
    let arrivalTime: TextValue
    let departureTime: TextValue
    let distance: TextValue
    let duration: TextValue
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
    let distance: TextValue
    let duration: TextValue
    let endLocation: Location
    let startLocation: Location
    let polyline: Polyline
    let transitDetails: Transit?
    let travelMode: String // "TRANSIT"
    let steps: Array<Step?>
    let transferPath: Array<Transfer>?
    
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
    }
}

struct Transfer: Hashable, Codable {
    let imgPath: String
    let mvContDtl: Array<String>
}

struct Transit: Hashable, Codable {
    let arrivalStop: LocationName
    let arrivalTime: TextValue
    let departureStop: LocationName
    let departureTime: TextValue
    let line: Line
    let numStops: String // 7 (7개 정류장 간다는 뜻인 듯)
    
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
    let color: String       // #9a4f11    ?
    let name: String        // 서울 지하철
    let shortName: String  // 6호선       ?
    let textColor: String  // #000000    ?
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
    let icon: String // "//maps.gstatic.com/mapfiles/transit/iw2/6/subway2.png" 지하철 이모티콘
    // 앞에 http:// 붙여줘야 함.
    let type: String // type
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

struct TextValue: Hashable, Codable {
    let text: String        // "25분" or "6.5 km" or "7:41 PM"
    let value: Int          // 6534   or   1713091260
    let timeZone: String?  // "Asia/Seoul"
    
    enum CodingKeys: String, CodingKey {
        case text
        case value
        case timeZone = "time_zone"
    }
}
