//
//  DirectionDataServiceDelegate.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/26/24.
//

import Foundation

protocol DirectionDataServiceDelegate: AnyObject {
    func directionDataService(_ service: DirectionDataService, didDownlad: Direction)
}
