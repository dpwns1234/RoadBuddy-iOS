//
//  ViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/6/24.
//

import UIKit
import GoogleMaps
import GooglePlaces

protocol SearchResultDelegate: AnyObject {
    func moveTabBarViewController()
}

final class SearchResultViewController: UIViewController {
    
    // MARK: - UI Properties
    
    private lazy var searchStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(searchTextField)
        stackView.addArrangedSubview(xButton)
        stackView.spacing = 24
        
        return stackView
    }()
    
    private var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.backButton, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private var xButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.xButton, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private var searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        textField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textField.textColor = .black
        
        return textField
    }()
    
    private var stackViewUnderLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        
        return view
    }()
    
    // MARK: - GoogleMap Property
    
    private var mapView: GMSMapView!
    private var locationManager: CLLocationManager!
    private var placesClient: GMSPlacesClient!
    private var preciseLocationZoomLevel: Float = 15.0
    private var approximateLocationZoomLevel: Float = 10.0
    
    private let addressData: Address?
    
    init(addressData: Address) {
        self.addressData = addressData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        initializeLocationManager()
        configureUI()
        setAction()
        searchTextField.text = addressData!.title
        displayBottomSheet()
    }
    
    private func initializeLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        placesClient = GMSPlacesClient.shared()
    }
    
    private func displayBottomSheet() {
        let bottomVC = BottomSheetViewController(addressData: addressData!)
        if let sheet = bottomVC.sheetPresentationController {
            let small = UISheetPresentationController.Detent.custom { context in
                let screenSize = UIScreen.main.bounds.size
                return screenSize.height * 0.2
            }
            sheet.detents = [small]
            sheet.largestUndimmedDetentIdentifier = .some(small.identifier)
            sheet.prefersGrabberVisible = true
        }
        
        bottomVC.delegate = self
        present(bottomVC, animated: true)
    }
}

// MARK: - Configure Button Actoin

extension SearchResultViewController {
    
    private func setAction() {
        searchTextField.addTarget(self, action: #selector(moveSearchViewController), for: .touchDown)
        backButton.addTarget(self, action: #selector(moveSearchViewController), for: .touchUpInside)
        xButton.addTarget(self, action: #selector(moveMainViewController), for: .touchUpInside)
    }
    
    @objc
    private func moveSearchViewController() {
        dismiss(animated: false)
        navigationController?.popViewController(animated: false)
    }
    
    @objc
    private func moveMainViewController() {
        UserDefaults.standard.removeObject(forKey: "departure")
        UserDefaults.standard.removeObject(forKey: "arrival")
        guard let mainViewController = navigationController?.viewControllers[0] else { return }
        dismiss(animated: false)
        navigationController?.popToViewController(mainViewController, animated: false)
    }
}

// MARK: - SearchResultDelegate

extension SearchResultViewController: SearchResultDelegate {
    
    func moveTabBarViewController() {
        guard var controllers = navigationController?.viewControllers else { return }
        let tabBarViewController = TabBarViewController()
        controllers.removeSubrange(1...)
        controllers.append(tabBarViewController)
        self.navigationController?.setViewControllers(controllers, animated: true)
    }
}

// MARK: - Configure Layout

extension SearchResultViewController {
    
    private func configureUI() {
        configureMapView()
        
        self.view.addSubview(searchStackView)
        self.view.addSubview(stackViewUnderLineView)
        setConstraints()
    }
    
    private func configureMapView() {
        let location = addressData?.geocoding.addresses[0].location ?? Location(lat: 37.588458, lng: 127.006221)
        let defaultLocation = CLLocation(latitude: location.lat, longitude: location.lng)
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView()
        mapView.camera = camera
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        
        setMarker(location)
        view.addSubview(mapView)
    }
    
    private func setMarker(_ location: Location) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
        marker.title = addressData?.title
        marker.snippet = addressData?.category
        marker.icon = GMSMarker.markerImage(with: Hansung.darkBlue.color)
        marker.map = mapView
    }
    
    private func setConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchStackView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            searchStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            searchStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            searchStackView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.08),
            
            backButton.centerYAnchor.constraint(equalTo: searchStackView.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: searchStackView.leadingAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 12),
            
            searchTextField.centerYAnchor.constraint(equalTo: searchStackView.centerYAnchor),
            searchTextField.trailingAnchor.constraint(equalTo: xButton.leadingAnchor),
            
            xButton.centerYAnchor.constraint(equalTo: searchStackView.centerYAnchor),
            xButton.trailingAnchor.constraint(equalTo: searchStackView.trailingAnchor),
            xButton.widthAnchor.constraint(equalToConstant: 16),
            
            stackViewUnderLineView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor),
            stackViewUnderLineView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            stackViewUnderLineView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            stackViewUnderLineView.heightAnchor.constraint(equalToConstant: 1),
            
            mapView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
        ])
    }
}
