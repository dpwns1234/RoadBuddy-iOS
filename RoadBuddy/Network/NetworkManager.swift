//
//  NetworkManager.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/29/24.
//

import Foundation

struct NetworkManager {
    private let username = "user"
    private let password = "3ca4b72e-3e98-4d08-94f5-e2a2a05e668e"
    
    func loadData(url: URL, leg: Data? = nil, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        var request = URLRequest(url: url)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        if leg != nil {
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = leg
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completionHandler(.failure(NetworkError.failedTask))
                return
            }
            guard
                let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode)
            else {
                return completionHandler(.failure(NetworkError.notSuccessCode))
            }
            
            guard let data = data else {
                return completionHandler(.failure(NetworkError.failedToLoadData))
            }
            
            completionHandler(.success(data))
        }.resume()
    }
}
