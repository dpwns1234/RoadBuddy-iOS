//
//  SearchHistoryConfiguration.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/18/24.
//

import UIKit

struct SearchHistoryConfiguration: UIContentConfiguration {
    var title: String?
    var created: Date?
    var removeAction: (() -> Void)?
    
    func makeContentView() -> UIView & UIContentView {
        return SearchHistoryContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> SearchHistoryConfiguration {
        return self
    }
}
