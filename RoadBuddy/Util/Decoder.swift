//
//  Decoder.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/22/24.
//

import Foundation

final class Decoder<T: Decodable> {
    private let decoder = JSONDecoder()
    
    func decode(data: Data) -> T? {
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            print("Fail decode: \(error)")
        }
        return nil
    }
}
