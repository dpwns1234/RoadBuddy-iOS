//
//  SearchHistoryCollectionViewCell.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/17/24.
//

import UIKit

final class SearchHistoryCollectionViewCell: UICollectionViewListCell {
    var item: SearchHistory!
    var removeAction: (() -> Void)?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var config = SearchHistoryConfiguration().updated(for: state)
        config.title = item.title
        config.created = item.created
        config.removeAction = removeAction
        self.contentConfiguration = config
    }
}
