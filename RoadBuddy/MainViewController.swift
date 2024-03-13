//
//  ViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/6/24.
//

import UIKit
import GoogleMaps

class MainViewController: UIViewController {
    private var searchBarTextField: UITextField = {
        let textField = FilterTextField(content: "장소, 버스, 지하철, 주소 검색", backgroundColor: .white)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private var findingWayButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    
    private var mapView: GMSMapView!
    
    override func loadView() {
        super.loadView()
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 12)
        self.mapView = GMSMapView(frame: .zero, camera: camera)
        self.view = mapView
        self.mapView.delegate = self
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    private func configureUI() {
        self.view.addSubview(searchBarTextField)
        self.view.addSubview(findingWayButton)
        
        setConstraints()
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

extension MainViewController: GMSMapViewDelegate {
    
}
