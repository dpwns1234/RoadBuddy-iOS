//
//  BottomSheetViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/28/24.
//

import UIKit

final class BottomSheetViewController: UIViewController {
    weak var delegate: SearchResultDelegate?
    private let modalView: BottomSheetView?
    private var place: String
    
    init(addressData: Address) {
        modalView = BottomSheetView(model: addressData)
        place = addressData.name
        super.init(nibName: nil, bundle: nil)
        
        modalView?.departureButton.addTarget(self, action: #selector(tappedDirectButton), for: .touchUpInside)
        modalView?.arrivalButton.addTarget(self, action: #selector(tappedDirectButton), for: .touchUpInside)
    }
    
    // TODO: 이제 route에서 둘 다 채워졌을 경우 체크해서 길찾기 셀 채윅
    @objc
    private func tappedDirectButton(_ sender: UIButton) {
        dismiss(animated: false)
        if sender == modalView?.departureButton {
            UserDefaults.standard.setValue(place, forKey: "departure")
            delegate?.moveRouteVC()
        } else {
            UserDefaults.standard.setValue(place, forKey: "arrival")
            delegate?.moveRouteVC()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = modalView
    }
}
