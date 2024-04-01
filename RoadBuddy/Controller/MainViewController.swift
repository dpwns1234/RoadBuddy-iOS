//
//  ViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/6/24.
//

import UIKit
import GoogleMaps
import GooglePlaces

final class MainViewController: UIViewController {
    private var searchBarTextField: UITextField = {
        let textField = FilterTextField(content: "장소, 버스, 지하철, 주소 검색", backgroundColor: .white)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private var findingWayButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // 그림자 효과
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 2.0
        
        let image = UIImage(named: "direction")
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private var mapView: GMSMapView!
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    private var placesClient: GMSPlacesClient!
    private var preciseLocationZoomLevel: Float = 15.0
    private var approximateLocationZoomLevel: Float = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLocationManager()
        configureUI()
        searchBarTextField.addTarget(self, action: #selector(moveSearchViewController), for: .touchDown)
    }
    
    @objc
    private func moveSearchViewController() {
        let searchViewController = SearchViewController()
        navigationController?.pushViewController(searchViewController, animated: true)
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
}

extension MainViewController: GMSMapViewDelegate {
//    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
//        // TODO: 권한 분기처리
////        showRequestLocationServiceAlert()
//        return true
//    }
}

extension MainViewController: CLLocationManagerDelegate {
    
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
extension MainViewController {
    
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

extension MainViewController {
    
    private func configureUI() {
        configureMapView()
        
        self.view.addSubview(searchBarTextField)
        self.view.addSubview(findingWayButton)
        setConstraints()
    }
    
    private func configureMapView() {
        let defaultLocation = CLLocation(latitude: 37.588458, longitude: 127.006221)
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        view.addSubview(mapView)
    }
    
    private func setConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchBarTextField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            searchBarTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            searchBarTextField.trailingAnchor.constraint(equalTo: findingWayButton.leadingAnchor, constant: -8),
            
            findingWayButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            findingWayButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            
        ])
    }
}
