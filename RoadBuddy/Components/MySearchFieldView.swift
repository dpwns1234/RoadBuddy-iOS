//
//  MySearchField.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/27/24.
//

import UIKit

final class MySearchFieldView: UIView {
    let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.backButton, for: .normal)
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    let searchTextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Search"
        
        return textField
    }()
    
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.addSubview(backButton)
        self.addSubview(searchTextField)
        
        setConstraints()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: self.topAnchor),
            backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            
            searchTextField.topAnchor.constraint(equalTo: self.topAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
