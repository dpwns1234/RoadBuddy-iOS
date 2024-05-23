//
//  DriveDataServiceDelegate.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/22/24.
//

import Foundation

protocol DriveDataServiceDelegate: AnyObject {
    func driveDataService(_ service: DriveDataService, didDownlad drive: Drive)
}
