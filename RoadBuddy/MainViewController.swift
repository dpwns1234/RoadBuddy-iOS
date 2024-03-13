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
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        // 그림자 효과
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 2.0
        
        let image = UIImage(named: "direction_on")
        button.setImage(image, for: .normal)
        return button
    }()
    
    private var currentLocationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.layer.cornerRadius = 40 / 2
        button.clipsToBounds = true
        
        let image = UIImage(named: "direction_off")
        button.setImage(image, for: .normal)
        
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
        self.view.addSubview(currentLocationButton)
        
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
            
            currentLocationButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -32),
            currentLocationButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
        ])
    }
}

extension MainViewController: GMSMapViewDelegate {
    
}
