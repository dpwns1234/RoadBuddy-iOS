//
//  SearchModel.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/1/24.
//

import Foundation

// TODO: created추가해도 괜찮나? 모델에 없는 변수, 필요없는 데이터는 안 받아도 괜찮나? 데이터 모델에 없는 것은 안 받아오려나?
// TODO: 그 카멜케이스 변환하는거 적용하기
// TODO: inner struct 하기?

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

//
//    "predictions": [
//        {
//            "description": "South Korea, 서울",
//            "matched_substrings": [
//                {
//                    "length": 2,
//                    "offset": 13
//                }
//            ],
//            "place_id": "ChIJzzlcLQGifDURm_JbQKHsEX4",
//            "reference": "ChIJzzlcLQGifDURm_JbQKHsEX4",
//            "structured_formatting": {
//                "main_text": "서울",
//                "main_text_matched_substrings": [
//                    {
//                        "length": 2,
//                        "offset": 0
//                    }
//                ],
//                "secondary_text": "South Korea"
//            },
//            "terms": [
//                {
//                    "offset": 13,
//                    "value": "서울"
//                },
//                {
//                    "offset": 0,
//                    "value": "South Korea"
//                }
//            ],
//            "types": [
//                "administrative_area_level_1",
//                "political",
//                "geocode"
//            ]
//        },
