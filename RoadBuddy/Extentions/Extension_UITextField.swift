//
//  Extension_UITextField.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/12/24.
//

import UIKit

extension UITextField {
    
    func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
    
    func changePlaceholderText(content: String, color: UIColor) {
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
             .font: UIFont.preferredFont(forTextStyle: .body),
             .foregroundColor: color
         ]
        self.attributedPlaceholder = NSAttributedString(string: content, attributes: placeholderAttributes)
    }
}
