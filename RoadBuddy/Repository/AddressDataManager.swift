//
//  AddressDataManager.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/8
//

import UIKit

protocol AddressDataManagerDelegate: AnyObject {
    func addressData(_ dataManager: AddressDataManager, didLoad addresses: [Address])
}

final class AddressDataManager {
    weak var delegate: AddressDataManagerDelegate?
    
    // MARK: Private property
    private let searchDataService = SearchDataService()
    private let locationRepository = UserDefaultRepository<Location>()
    
    // MARK: Data
    private var address: [Address]?
    
    init() {
        searchDataService.delegate = self
    }
    
    func fetchData(input: String) {
        do {
            let location = locationRepository.fetch(type: "currentLocation")
            try searchDataService.convertData(type: .address(search: input, currentLocatoin: location))
        } catch {
            print(error)
        }
    }
}

// MARK: - SearchDataServiceDelegate

extension AddressDataManager: SearchDataServiceDelegate {
    
    func searchDataService(_ service: SearchDataService, didDownload data: [Address]) {
        self.address = data
        self.delegate?.addressData(self, didLoad: data)
    }
}
