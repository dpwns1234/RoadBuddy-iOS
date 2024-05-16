//
//  TransferDataServiceDelegate.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/16/24.
//

import Foundation

protocol TransferDataServiceDelegate: AnyObject {
    func legDataService(_ service: TransferDataService, didDownlad leg: Leg)
}
