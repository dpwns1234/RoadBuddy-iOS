//
//  RouteResultViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/17/24.
//

import UIKit
import GoogleMaps
import GooglePlaces

final class RouteResultViewController: UIViewController {
    
    // MARK: - UI Properties
    
    // TODO: 네비게이션 백버튼만 사용하던가(단독으로 사용할 수 있을진 모르겠음) / 동그라미 만들어서 배치 하던가
    private var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.backButton, for: .normal)
        button.imageView?.contentMode = .center
        
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        
        // Set the background color to white
        button.backgroundColor = .white
        
        // Make the button circular
        button.layer.cornerRadius = button.frame.size.width / 2
        button.clipsToBounds = true
        
        return button
    }()
    
    // MARK: - GoogleMap Property
    
    private var mapView: GMSMapView!
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    private var placesClient: GMSPlacesClient!
    private var preciseLocationZoomLevel: Float = 15.0
    private var approximateLocationZoomLevel: Float = 10.0
    
    private let leg: Leg?
    
    init(leg: Leg) {
        self.leg = leg
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
        drawPolyline(steps: leg?.steps)
        
        backButton.addTarget(self, action: #selector(moveRouteViewController), for: .touchUpInside)
        displayBottomSheet()
    }
    
    @objc
    private func moveRouteViewController() {
        dismiss(animated: false)
        navigationController?.popViewController(animated: false)
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
        let bottomVC = BottomSheetViewController(leg: leg!)
        if let sheet = bottomVC.sheetPresentationController {
            let zero = UISheetPresentationController.Detent.custom { context in
                let screenSize = UIScreen.main.bounds.size
                return screenSize.height * 0.01
            }
            sheet.detents = [.medium(), zero]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.selectedDetentIdentifier = .medium
        }
        
        present(bottomVC, animated: true)
    }
}

extension RouteResultViewController: GMSMapViewDelegate {
//    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
//        // TODO: 권한 분기처리
////        showRequestLocationServiceAlert()
//        return true
//    }
}

extension RouteResultViewController: CLLocationManagerDelegate {
    
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

extension RouteResultViewController {
    
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

extension RouteResultViewController {
    
    private func configureUI() {
        configureMapView()
        self.view.addSubview(backButton)
        setConstraints()
    }
    
    private func configureMapView() {
        guard
            let startLocation = leg?.startLocation,
            let endLocation = leg?.endLocation
        else {
            print("leg is nil!")
            return
        }
        let departureLocation = CLLocationCoordinate2D(latitude: startLocation.lat, longitude: startLocation.lng)
        let arrivalLocation = CLLocationCoordinate2D(latitude: endLocation.lat, longitude: endLocation.lng)
        
        mapView = GMSMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        view.addSubview(mapView)
        
        let bounds = GMSCoordinateBounds(coordinate: departureLocation, coordinate: arrivalLocation)
        let insets = UIEdgeInsets(top: 0.0, left: 100.0, bottom: 400.0, right: 100.0)
        let update = GMSCameraUpdate.fit(bounds, with: insets)
        mapView.moveCamera(update)
        
//        setMarker(location)
    }
    
    func midpointCoordinate(first: CLLocationCoordinate2D, second: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let latitude = (first.latitude + second.latitude) / 2.0
        let longitude = (first.longitude + second.longitude) / 2.0
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func adjustLatitude(coordinate: CLLocationCoordinate2D, offset: Double) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: coordinate.latitude - offset, longitude: coordinate.longitude)
    }

    
    private func drawPolyline(steps: [Step]?) {
        guard let steps = steps else { return }
        
        for step in steps {
            let path = GMSMutablePath(fromEncodedPath: step.polyline.points)
            let polyline = GMSPolyline(path: path)
            polyline.geodesic = true
            polyline.strokeWidth = 7.0
            
            if let transitDetails = step.transitDetails {
                polyline.strokeColor = UIColor(hex: transitDetails.line.color)!
            } else {
                drawPolyline(polyline: polyline)
            }
            polyline.map = mapView
        }
    }
    
    private func drawPolyline(polyline: GMSPolyline) {
        polyline.strokeWidth = 10.0
        let image = UIImage(named: "sprite5")!
        let stampStyle = GMSSpriteStyle(image: image)
        let transparentStampStroke = GMSStrokeStyle.transparentStroke(withStamp: stampStyle)
        let span = GMSStyleSpan(style: transparentStampStroke)
        polyline.spans = [span]
        polyline.zIndex = 1
    }
    
    // TODO: 마커도 출발지, 도착지, 급경사지 다 체크
    private func setMarker(_ location: Location) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
        marker.title = "출발"
        marker.icon = GMSMarker.markerImage(with: Hansung.darkBlue.color)
        marker.map = mapView
    }
    
    private func setConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48),
            
            mapView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
        ])
    }
}
