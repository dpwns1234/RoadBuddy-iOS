//
//  MainButton.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/28/24.
//

import UIKit

final class MainButton: UIButton {
    private var status: Status
    
    init(status: Status, titleText: String) {
        self.status = status
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(titleText, for: .normal)
        self.heightAnchor.constraint(equalToConstant: 40).isActive = true
        setUI()
    }
    
    private func setUI() {
        self.titleLabel?.font = status.font
        self.setTitleColor(status.textColor, for: .normal)
        self.backgroundColor = status.backgroundColor
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 1
        self.layer.borderColor = status.textColor.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainButton {
    enum Status {
        case on
        case off
    }
}

extension MainButton.Status {
    var font: UIFont { UIFont.preferredFont(forTextStyle: .caption1) }
    
    var textColor: UIColor {
        switch self {
        case .on:
            return UIColor.white
        case .off:
            return Hansung.blue.color
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .on:
            return Hansung.blue.color
        case .off:
            return UIColor.white
        }
    }
}
