//
//  DataServiceable.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/29/24.
//

import Foundation

protocol DataServiceable: AnyObject {
    var decoder: JSONDecoder { get }
    var networkManager: NetworkManager { get }
    
    func convertData(type service: ServiceType) throws
}

extension DataServiceable {
    var decoder: JSONDecoder {
        return JSONDecoder()
    }
    var networkManager: NetworkManager {
        return NetworkManager()
    }
}
