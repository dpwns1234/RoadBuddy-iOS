//
//  UserDefaultRepository.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/22/24.
//

import Foundation

final class UserDefaultRepository<T: Codable> {
    private let encoder = Encoder<T>()
    private let decoder = Decoder<T>()
    
    func save(data: T) {
        if let encoded = encoder.encode(data: data) {
            UserDefaults.standard.setValue(encoded, forKey: "searchHistories")
            UserDefaults.standard.synchronize()
        }
    }
    
    func fetch() -> T? {
        guard let data = UserDefaults.standard.data(forKey: "searchHistories") else { return nil }
        return decoder.decode(data: data)
    }
}
