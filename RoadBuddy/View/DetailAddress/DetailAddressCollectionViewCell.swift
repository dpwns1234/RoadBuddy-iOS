//
//  DetailAddressCollectionViewCell.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/22/24.
//

import UIKit

final class DetailAddressCollectionViewCell: UICollectionViewListCell {
    var item: SearchDataModel!
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var config = DetailAddressConfiguration()
        config.title = item.title
        config.address = item.address
        config.category = item.category
        config.distance = item.distance
        self.contentConfiguration = config
    }
}
