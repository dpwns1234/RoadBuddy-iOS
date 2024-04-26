//
//  NetworkManager.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/29/24.
//

import Foundation

struct NetworkManager {
    private let username = "user"
    private let password = "4fd3fcbb-4825-4fd0-a28b-f31b1d4ed718"
    
    func loadData(url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        var request = URLRequest(url: url)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
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
