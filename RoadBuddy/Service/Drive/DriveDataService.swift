//
//  DriveDataService.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/22/24.
//

import Foundation

final class DriveDataService: DataServiceable {
    weak var delegate: DriveDataServiceDelegate?
    
    func convertData(type service: ServiceType) throws {
        guard let url = service.makeURL() else { throw NetworkError.invailedURL }
        networkManager.loadData(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let decodeData = try self.decoder.decode(Drive.self, from: data)
                    self.delegate?.driveDataService(self, didDownlad: decodeData)
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
