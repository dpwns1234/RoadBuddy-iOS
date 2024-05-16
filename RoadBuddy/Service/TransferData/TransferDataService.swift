//
//  TransferDataService.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/16/24.
//

import Foundation

final class TransferDataService {
    weak var delegate: TransferDataServiceDelegate?
    
    private let networkManager = NetworkManager()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    func convertData(type service: ServiceType, leg: Leg) {
        guard let url = service.makeURL() else {
            print(NetworkError.invailedURL)
            return
        }
        let encodedData = try? encoder.encode(leg)
        self.networkManager.loadData(url: url, leg: encodedData) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedData = try self.decoder.decode(LegData.self, from: data)
                    self.delegate?.legDataService(self, didDownlad: decodedData.data)
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
