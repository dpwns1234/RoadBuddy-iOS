//
//  BottomSheetViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/28/24.
//

import UIKit

final class BottomSheetViewController: UIViewController {
    weak var delegate: SearchResultDelegate?
    private let modalView: UIView?
    private let addressRepository = UserDefaultRepository<Address>()
    private var place: Address?
    
    init(addressData: Address) {
        self.modalView = BottomSheetView(model: addressData)
        self.place = addressData
        super.init(nibName: nil, bundle: nil)
        
        guard let modalView = modalView as? BottomSheetView else { return }
        modalView.departureButton.addTarget(self, action: #selector(tappedDirectButton), for: .touchUpInside)
        modalView.arrivalButton.addTarget(self, action: #selector(tappedDirectButton), for: .touchUpInside)
    }
    
    init(route: Route) {
        self.modalView = BottomSheetRouteView(route: route)
        self.place = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    // TODO: type enum으로 바꾸기 + UserDefualts enum 수정 및 save, fetch 리팩터
    @objc
    private func tappedDirectButton(_ sender: UIButton) {
        dismiss(animated: false)
        guard var place = place else {
            print("Place is nil")
            return
        }
        guard let modalView = modalView as? BottomSheetView else { return }
        if sender == modalView.departureButton {
            place.type = "departure"
            addressRepository.save(data: place)
            delegate?.moveRouteVC()
        } else {
            place.type = "arrival"
            addressRepository.save(data: place)
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
