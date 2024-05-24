//
//  FilterTextField.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/13/24.
//

import UIKit


// 다른 점: placeholder, 배경색
final class FilterTextField: UITextField {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(content: String, backgroundColor: UIColor) {
        super.init(frame: .zero)
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
             .font: UIFont.preferredFont(forTextStyle: .body),
             .foregroundColor: UIColor.lightGray
         ]
        self.attributedPlaceholder = NSAttributedString(string: content, attributes: placeholderAttributes)
        
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = 10
        self.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // 그림자 효과
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 2.0
    }
    
    // placeholder 패딩
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 0)
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 0)
        return bounds.inset(by: padding)
    }
}
