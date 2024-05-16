//
//  Extension+String.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/16/24.
//

import Foundation

extension String {
    // HTML 태그 제거 함수
    func removingHTMLEntities() -> String? {
        guard let data = self.data(using: .utf8) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else { return nil }
        return attributedString.string
    }
}
