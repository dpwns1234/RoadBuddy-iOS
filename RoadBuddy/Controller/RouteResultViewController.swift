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
    
    private var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 40),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        button.backgroundColor = .white
        
        // Make the button circular
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        
        button.setImage(.backButton, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        let imageInset: CGFloat = 10
        button.imageEdgeInsets = UIEdgeInsets(top: imageInset, left: imageInset, bottom: imageInset, right: imageInset)
        
        return button
    }()
    
    // MARK: - GoogleMap Property
    
    private var mapView: GMSMapView!
    private var locationManager: CLLocationManager!
    private var placesClient: GMSPlacesClient!
    
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
        let bottomVC = BottomSheetViewController(leg: leg!)
        bottomVC.routeResultDelegate = self
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

// MARK: - Configure Layout

extension RouteResultViewController {
    
    private func configureUI() {
        configureMapView()
        self.view.addSubview(backButton)
        backButton.addTarget(self, action: #selector(moveTabBarViewController), for: .touchUpInside)
        setConstraints()
    }
    
    @objc
    private func moveTabBarViewController() {
        dismiss(animated: false)
        navigationController?.popViewController(animated: false)
    }
    
    private func configureMapView() {
        guard
            let startLocation = leg?.startLocation,
            let endLocation = leg?.endLocation
        else {
            print("leg is nil!")
            return
        }
        let departureCoordinate = CLLocationCoordinate2D(latitude: startLocation.lat, longitude: startLocation.lng)
        let arrivalCoordinate = CLLocationCoordinate2D(latitude: endLocation.lat, longitude: endLocation.lng)
        
        mapView = GMSMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        view.addSubview(mapView)
        
        let bounds = GMSCoordinateBounds(coordinate: departureCoordinate, coordinate: arrivalCoordinate)
        let insets = UIEdgeInsets(top: 50.0, left: 150.0, bottom: 450.0, right: 150.0)
        let update = GMSCameraUpdate.fit(bounds, with: insets)
        mapView.moveCamera(update)
        
        setMarker(departureCoordinate, color: Hansung.blue.color)
        setMarker(arrivalCoordinate, color: .red)
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
    
    private func setMarker(_ pointCoordinate: CLLocationCoordinate2D, color: UIColor) {
        let marker = GMSMarker()
        marker.position = pointCoordinate
        marker.title = "출발"
        marker.icon = GMSMarker.markerImage(with: color)
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

// MARK: - BottomSheetViewControllerDelegate

extension RouteResultViewController: BottomSheetViewControllerDelegate {
    
    func setSteepSlope(didLoad leg: Leg) {
        DispatchQueue.main.async {
            self.setMarker(steps: leg.steps)
        }
    }
    
    func updateCamera(path fromEncodedPath: String) {
        guard let path = GMSPath(fromEncodedPath: fromEncodedPath) else { return }
        let bounds = GMSCoordinateBounds(path: path)
        let insets = UIEdgeInsets(top: 50.0, left: 150.0, bottom: 450.0, right: 150.0)
        let update = GMSCameraUpdate.fit(bounds, with: insets)
        mapView.animate(with: update)
    }
    
    private func setMarker(steps: [Step]) {
        for step in steps {
            guard let steepSlopes = step.steepSlopes else { continue }
            for steepSlope in steepSlopes {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: steepSlope.latitude, longitude: steepSlope.longitude)
                marker.title = steepSlope.shortAddress
                marker.icon = GMSMarker.markerImage(with: .yellow)
                marker.map = self.mapView
            }
        }
    }
}
