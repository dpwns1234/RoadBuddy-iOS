//
//  Encoder.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/22/24.
//

import Foundation

final class Encoder<T: Encodable> {
    private let encoder = JSONEncoder()
    
    func encode(data: T) -> Data? {
        do {
            let encoded = try encoder.encode(data)
            return encoded
        } catch {
            print("Fail Encode: \(error)")
        }
        return nil
    }
}
