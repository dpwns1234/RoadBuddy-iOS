//
//  HansungColor.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/28/24.
//

import UIKit

enum Hansung: UInt {
    case skyBlue = 0x049EDB
    case blue = 0x0A4DA1
    case darkBlue = 0x032E6E
    case grey = 0x626466
    case lightGrey = 0xECECEC
    
    var color: UIColor {
        return UIColor(hex: self.rawValue)
    }
}
