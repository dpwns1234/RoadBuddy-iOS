//
//  UserDefaultRepository.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/25/24.
//

import UIKit

final class UserDefaultRepository<T: Codable> {
    
    func save(data: T) {
        let encoder = Encoder<T>()
        let encoded = encoder.encode(data: data)
        switch data {
        case is [SearchDataModel]:
            UserDefaults.standard.setValue(encoded, forKey: "searchHistories")
        case is Address:
            guard let address = data as? Address else {
                print("address is nil!")
                return
            }
            if address.type == "departure" {
                UserDefaults.standard.set(encoded, forKey: address.type!)
            } else {
                UserDefaults.standard.set(encoded, forKey: address.type!)
            }
        case is Location:
            UserDefaults.standard.setValue(encoded, forKey: "currentLocation")
        default:
            print("default")
        }
    }
    
    func fetch(type: String) -> T? {
        let decoder = Decoder<T>()
        let data: Data?
        switch type {
        case "search":
            data = UserDefaults.standard.object(forKey: "searchHistories") as? Data
        case "departure":
            data = UserDefaults.standard.object(forKey: "departure") as? Data
        case "arrival":
            data = UserDefaults.standard.object(forKey: "arrival") as? Data
        case "currentLocation":
            data = UserDefaults.standard.object(forKey: "currentLocation") as? Data
        default:
            data = nil
        }
        guard let data = data else { return nil }
        return decoder.decode(data: data)
    }
}
