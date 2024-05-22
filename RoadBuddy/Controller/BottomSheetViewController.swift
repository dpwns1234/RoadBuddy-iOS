//
//  BottomSheetViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/28/24.
//

import UIKit

final class BottomSheetViewController: UIViewController {
    weak var delegate: SearchResultDelegate?
    weak var routeResultDelegate: RouteResultDelegate?
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    
    private var modalView: UIView?
    
    private let addressRepository = UserDefaultRepository<Address>()
    private let transferDataService = TransferDataService()
    private var place: Address?
    
    init(addressData: Address) {
        self.modalView = BottomSheetView(model: addressData)
        self.place = addressData
        super.init(nibName: nil, bundle: nil)
        
        guard let modalView = modalView as? BottomSheetView else { return }
        modalView.departureButton.addTarget(self, action: #selector(tappedDirectButton), for: .touchUpInside)
        modalView.arrivalButton.addTarget(self, action: #selector(tappedDirectButton), for: .touchUpInside)
    }
    
    init(leg: Leg) {
        self.modalView = UIImageView(image: .wating)
        self.place = nil
        super.init(nibName: nil, bundle: nil)
        self.view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        transferDataService.delegate = self
        
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
        transferDataService.convertData(type: .transfer, leg: leg)
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
            delegate?.moveTabBarViewController()
        } else {
            place.type = "arrival"
            addressRepository.save(data: place)
            delegate?.moveTabBarViewController()
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

extension BottomSheetViewController: TransferDataServiceDelegate {
    
    func legDataService(_ service: TransferDataService, didDownlad leg: Leg) {
        
        // 여기서 RouteResultVC에 급경사로 리스트 보내주기가 아닌 Leg 데이터 보내주기
        routeResultDelegate?.setSteepSlope(didLoad: leg)
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            self.modalView = BottomSheetRouteView(leg: leg)
            self.view = self.modalView
            self.loadViewIfNeeded()
            
            
        }
    }
    
}
