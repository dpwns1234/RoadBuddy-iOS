//
//  NetworkError.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/29/24.
//

import Foundation

enum NetworkError: Error, CustomStringConvertible {
    case invailedURL
    case failedToLoadData
    case notSuccessCode
    case failedTask
    
    var description: String {
        switch self {
        case .invailedURL:
            "API url이 유효하지 않습니다."
        case .failedToLoadData:
            "data를 받아오지 못했습니다."
        case .notSuccessCode:
            "200번대 코드가 아닙니다."
        case .failedTask:
            "dataTask에 실패했습니다."
        }
    }
}
