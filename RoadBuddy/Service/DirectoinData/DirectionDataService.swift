//
//  DirectionDataService.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/26/24.
//

import Foundation

final class DirectionDataService: DataServiceable {
    weak var delegate: DirectionDataServiceDelegate?
    
    func convertData(type service: ServiceType) {
        guard let url = service.makeURL() else { 
            print(NetworkError.invailedURL)
            return
        }
        self.networkManager.loadData(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedData = try self.decoder.decode(Direction.self, from: data)
                    self.delegate?.directionDataService(self, didDownlad: decodedData)
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
