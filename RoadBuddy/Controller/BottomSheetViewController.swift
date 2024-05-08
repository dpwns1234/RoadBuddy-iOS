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
    private var place: Address
    private let addressRepository = UserDefaultRepository<Address>()
    
    init(addressData: Address) {
        modalView = BottomSheetView(model: addressData)
        place = addressData
        super.init(nibName: nil, bundle: nil)
        
        modalView?.departureButton.addTarget(self, action: #selector(tappedDirectButton), for: .touchUpInside)
        modalView?.arrivalButton.addTarget(self, action: #selector(tappedDirectButton), for: .touchUpInside)
    }
    
    
    // TODO: type enum으로 바꾸기 + UserDefualts enum 수정 및 save, fetch 리팩터
    @objc
    private func tappedDirectButton(_ sender: UIButton) {
        dismiss(animated: false)
        if sender == modalView?.departureButton {
            place.type = "departure"
            addressRepository.save(data: place)
            delegate?.moveRouteVC()
        } else {
            addressRepository.save(data: place)
            place.type = "arrival"
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
