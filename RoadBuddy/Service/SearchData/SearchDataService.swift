//
//  SearchDataService.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/29/24.
//

import Foundation

final class SearchDataService: DataServiceable {
    weak var delegate: SearchDataServiceDelegate?
    
    func convertData(type service: ServiceType) throws {
        guard let url = service.makeURL() else { throw NetworkError.invailedURL }
        networkManager.loadData(url: url) { result in
            switch result {
            case .success(let data):
                do {                    
                    let decodeData = try self.decoder.decode(AddressModel.self, from: data)
                    self.delegate?.searchDataService(self, didDownload: decodeData.data.items)
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
