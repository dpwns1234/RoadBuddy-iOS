//
//  BottomSheetViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/28/24.
//

import UIKit

final class BottomSheetViewController: UIViewController {
    
    private let model = SearchDataModel(title: "한성대학교2", address: "삼선교 어딘가2", category: "대학교2", distance: 124)
    
    private lazy var modalSheetView = BottomSheetView(model: model)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = modalSheetView
    }
}
