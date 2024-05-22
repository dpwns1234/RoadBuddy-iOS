//
//  DetailAddressConfiguration.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/22/24.
//

import UIKit

struct DetailAddressConfiguration: UIContentConfiguration {
    var title: String?
    var address: String?
    var category: String?
    var distance: Double?
    
    func makeContentView() -> UIView & UIContentView {
        return DetailAddressContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> DetailAddressConfiguration {
        return self
    }
}
