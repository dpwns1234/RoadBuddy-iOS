//
//  Direction.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/25/24.
//

import Foundation

struct Direction: Decodable {
    let data: ChangeTest
}

struct ChangeTest: Decodable {
    let routes: Array<Route>
}

struct Route: Hashable, Decodable {
    let bounds: Bound?
    let legs: Array<Leg>
}

// MARK: 중요데이터
struct Leg: Hashable, Decodable {
    let arrival_time: TextValue
    let departure_time: TextValue
    let distance: TextValue
    let duration: TextValue
    let end_address: String
    let end_location: Location
    let start_address: String
    let start_location: Location
    let steps: Array<Step>
}

// MARK: 중요 데이터
struct Step: Hashable, Decodable {
    let distance: TextValue
    let duration: TextValue
    let end_location: Location
    let start_location: Location
    let polyline: Polyline
    let transit_details: Transit?
    let travel_mode: String // "TRANSIT"
    let steps: Array<Step>
}

struct Transit: Hashable, Decodable {
    let arrival_stop: LocationName
    let arrival_time: TextValue
    let departure_stop: LocationName
    let departure_time: TextValue
    let line: Line
    let num_stops: Int // 7 (7개 정류장 간다는 뜻인 듯)
}

// MARK: 중요 데이터
struct Line: Hashable, Decodable {
    let color: String       // #9a4f11
    let name: String        // 서울 지하철
    let short_name: String  // 6호선
    let text_color: String  // #000000
    let vehicle: Vehicle
}

struct Vehicle: Hashable, Decodable {
    let icon: String // "//maps.gstatic.com/mapfiles/transit/iw2/6/subway2.png" 지하철 이모티콘
    // 앞에 http:// 붙여줘야 함.
    let type: String // type
}

struct LocationName: Hashable, Decodable {
    let location: Location
    let name: String
}

struct Polyline: Hashable, Decodable {
    let points: String
}


struct Bound: Hashable, Decodable {
    let northeast: Location
    let southwest: Location
}

struct TextValue: Hashable, Decodable {
    let text: String        // "25분" or "6.5 km" or "7:41 PM"
    let value: Int          // 6534   or   1713091260
    let time_zone: String?  // "Asia/Seoul"
}