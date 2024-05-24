//
//  DirectionDataManager.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/16/24.
//

import Foundation

protocol DirectionDataManagerDelegate: AnyObject {
    func directionData(_ dataManager: DirectionDataManager, didLoad direction: Direction)
}

final class DirectionDataManager {
    weak var delegate: DirectionDataManagerDelegate?
    
    // MARK: Private property
    private let directionDataService = DirectionDataService()
    
    // MARK: Data
    private var direcion: Direction?
    
    init() {
        directionDataService.delegate = self
    }
    
    func fetchDirection(departure departureLocation: Location, arrival arrivalLocation: Location) {
        directionDataService.convertData(type: .direction(departureLat: departureLocation.lat, departureLon: departureLocation.lng, arrivalLat: arrivalLocation.lat, arrivalLon: arrivalLocation.lng))
    }
}

// MARK: - DirectionDataServiceDelegate

extension DirectionDataManager: DirectionDataServiceDelegate {
    
    func directionDataService(_ service: DirectionDataService, didDownlad direction: Direction) {
        self.direcion = direction
        delegate?.directionData(self, didLoad: direction)
    }
}
