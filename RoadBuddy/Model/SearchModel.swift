//
//  SearchModel.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/1/24.
//

import Foundation

struct SearchModel {
    let predictions: [Prediction]
}

struct Prediction {
    let description: String
    let matchedSubstrings: [Substring]
    let placeId: String
    let reference: String
    let structuredFormatting: StructuredFormatting
    let terms: Array<Term>
    let types: Array<String>
}

struct Substring {
    let length: Int
    let offset: Int
}

struct StructuredFormatting {
    let mainText: String
    let mainTextMatchedSubstrings: [Substring]
    let secondaryText: String
}

struct Term {
    let offset: Int
    let value: String
}
