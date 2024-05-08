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
    func moveRouteVC()
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
    private var currentLocation: CLLocation?
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
        searchTextField.addTarget(self, action: #selector(moveSearchViewController), for: .touchDown)
        backButton.addTarget(self, action: #selector(moveSearchViewController), for: .touchUpInside)
        xButton.addTarget(self, action: #selector(moveMainViewController), for: .touchUpInside)
        searchTextField.text = addressData!.title
        displayBottomSheet()
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
    
    private func initializeLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 이거 실제 기기에서 테스트, 느리지 않는지
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50 // 50m 이동해야지만 업데이트 제공
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
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

// MARK: - SearchResultDelegate

extension SearchResultViewController: SearchResultDelegate {
    func moveRouteVC() {
        guard var controllers = navigationController?.viewControllers else { return }
        let routeVC = RouteViewController()
        controllers.removeSubrange(1...)
        controllers.append(routeVC)
        self.navigationController?.setViewControllers(controllers, animated: true)
    }
}

extension SearchResultViewController: GMSMapViewDelegate {
//    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
//        // TODO: 권한 분기처리
////        showRequestLocationServiceAlert()
//        return true
//    }
}

extension SearchResultViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // Handle authorization status
        switch status {
        case .restricted:
            print("Location access was restricted.")
            showLocationRestrictedAlert()
        case .denied:
            print("User denied access to location.")
            showRequestLocationServiceAlert()
        case .notDetermined:
            print("Location status not determined.")
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        default:
            fatalError()
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

// MARK: - Alerts
extension SearchResultViewController {
    
    func showRequestLocationServiceAlert() {
        let requestLocationServiceAlert = UIAlertController(title: "위치 정보 이용", message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
        let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .default)
        requestLocationServiceAlert.addAction(cancel)
        requestLocationServiceAlert.addAction(goSetting)
        
        present(requestLocationServiceAlert, animated: true)
    }
    
    func showLocationRestrictedAlert() {
        let locationRestrictedAlert = UIAlertController(title: "위치 제한 구역", message: "위치 서비스를 제한하는 구역에 있습니다.\n다시 시도해주세요.", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "확인", style: .default)
        locationRestrictedAlert.addAction(ok)
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
        let location = addressData?.location ?? Location(lat: 37.588458, lng: 127.006221)
        let defaultLocation = CLLocation(latitude: location.lat, longitude: location.lng)
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView()
        mapView.camera = camera
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
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
        
        
        // TODO: 그려지긴 하는데, 선이 이상하게 그려짐.. ㅠ 이유 모름 ㅋㅋ
        // 아마 ??? 이거 decoding 제대로 안 돼서 그런 듯.
        let encodedPolyline = "avjdFmtffW??Q@u@@?????b@????c@@CB????l@A????@p@?bA?x@?V? f@?FANADGVM`@CDGNOPONAJBF????]h@?F????YR_@\\????WQg@]aBrA????Ui@????G^?D???? OI????QVg@?u@@GHG@]A_@?????NhCCLBp@B^?lA@p@GRMBiAD??"
        
        // Decode polyline
        let path = GMSMutablePath(fromEncodedPath: encodedPolyline)
        
        // Create the polyline
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor.blue
        polyline.strokeWidth = 2.0
        polyline.map = mapView
        
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
