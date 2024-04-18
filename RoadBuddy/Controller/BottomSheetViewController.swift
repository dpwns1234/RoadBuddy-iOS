//
//  BottomSheetViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/28/24.
//

import UIKit

final class BottomSheetViewController: UIViewController {
    private let modalView: BottomSheetView?
    private var place: String
    
    init(addressData: Address) {
        modalView = BottomSheetView(model: addressData)
        place = addressData.name
        super.init(nibName: nil, bundle: nil)
        
        modalView?.departureButton.addTarget(self, action: #selector(tappedDirectButton), for: .touchUpInside)
        modalView?.arrivalButton.addTarget(self, action: #selector(tappedDirectButton), for: .touchUpInside)
    }
    
    // TODO: navigationController 없구나! 아이폰에서 어케 되는지 확인해보고 네비게이션이라면 closure나 delegate 사용해서 넘겨주기 -> 네비게이션 아님.
    @objc
    private func tappedDirectButton(_ sender: UIButton) {
        if sender == modalView?.departureButton {
            let searchPathViewController = SearchPathViewController(placeText: place, direct: .departure)
            searchPathViewController.modalPresentationStyle = .fullScreen
            present(searchPathViewController, animated: true)
            
        } else {
            let searchPathViewController = SearchPathViewController(placeText: place, direct: .arrival)
            searchPathViewController.modalPresentationStyle = .fullScreen
            present(searchPathViewController, animated: true)
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
