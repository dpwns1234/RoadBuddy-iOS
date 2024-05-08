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
        // TODO: 거리는 해결해야 함.
        config.distance = 0
        self.contentConfiguration = config
    }
}
