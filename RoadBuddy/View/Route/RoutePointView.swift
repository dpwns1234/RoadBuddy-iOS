//
//  RoutePointView.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/22/24.
//

import UIKit
import GoogleMaps

final class RoutePointView: UIView {
    private var pointImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    init(address: String, color: UIColor) {
        super.init(frame: .zero)
        
        backgroundColor = .white
        self.addSubview(addressLabel)
        self.addSubview(pointImageView)
        
        addressLabel.text = address
        pointImageView.image = GMSMarker.markerImage(with: color)
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints() {
        let safeArea = self.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            pointImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            pointImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            pointImageView.widthAnchor.constraint(equalToConstant: 40),
            pointImageView.heightAnchor.constraint(equalToConstant: 40),
            
            addressLabel.centerYAnchor.constraint(equalTo: pointImageView.centerYAnchor),
            addressLabel.leadingAnchor.constraint(equalTo: pointImageView.trailingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            addressLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            
        ])
    }
}
