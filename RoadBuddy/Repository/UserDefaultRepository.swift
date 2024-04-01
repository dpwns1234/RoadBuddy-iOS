//
//  UserDefaultRepository.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/25/24.
//

import UIKit

final class UserDefaultRepository<T: Codable> {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func save(data: T) {
        do {
            let encoded = try encoder.encode(data)
            UserDefaults.standard.setValue(encoded, forKey: "searchHistories")
        } catch {
            print("Failed encode: \(error)")
        }
    }
    
    func fetch() -> T? {
        let data = UserDefaults.standard.object(forKey: "searchHistories") as! Data
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Failed decode:\(error)")
        }
        return nil
    }
}
