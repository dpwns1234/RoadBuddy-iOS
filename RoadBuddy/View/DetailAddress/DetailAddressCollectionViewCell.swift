//
//  DetailAddressCollectionViewCell.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/22/24.
//

import UIKit

final class DetailAddressCollectionViewCell: UICollectionViewListCell {
    var item: Address!
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var config = DetailAddressConfiguration()
        config.title = item.title
        config.address = item.address
        config.category = item.category
        if item.geocoding.addresses.isEmpty == false {
            config.distance = Double(item.geocoding.addresses[0].distance)
        } else {
            config.distance = 0
        }
        self.contentConfiguration = config
    }
}
