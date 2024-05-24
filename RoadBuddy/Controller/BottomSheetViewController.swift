//
//  BottomSheetViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/28/24.
//

import UIKit
import CoreLocation

protocol BottomSheetViewControllerDelegate: AnyObject {
    func setSteepSlope(didLoad leg: Leg)
    func updateCamera(path fromEncodedPath: String)
}

final class BottomSheetViewController: UIViewController {
    weak var delegate: SearchResultDelegate?
    weak var routeResultDelegate: BottomSheetViewControllerDelegate?
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    
    private var modalView: UIView?
    
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
    
    init(leg: Leg) {
        self.modalView = UIImageView(image: .wating)
        self.place = nil
        super.init(nibName: nil, bundle: nil)
        self.view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        let transferDataService = TransferDataService()
        transferDataService.delegate = self
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
        transferDataService.convertData(type: .transfer, leg: leg)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = modalView
    }
}

// MARK: - For SearchResultViewController

extension BottomSheetViewController {
    
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
}

// MARK: - TransferDataServiceDelegate (For RouteResultViewController)

extension BottomSheetViewController: TransferDataServiceDelegate {
    
    func legDataService(_ service: TransferDataService, didDownlad leg: Leg) {
        routeResultDelegate?.setSteepSlope(didLoad: leg)
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            let bottomSheetRouteView = BottomSheetRouteView(leg: leg)
            bottomSheetRouteView.delegate = self
            self.modalView = bottomSheetRouteView
            self.view = self.modalView
            self.loadViewIfNeeded()
        }
    }
}

// MARK: - BottomSheetRouteDelegate

extension BottomSheetViewController: BottomSheetRouteDelegate {
    
    func updateCamera(path fromEncodedPath: String) {
        routeResultDelegate?.updateCamera(path: fromEncodedPath)
    }
}
