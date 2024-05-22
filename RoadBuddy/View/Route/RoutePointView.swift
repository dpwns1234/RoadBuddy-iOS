//
//  RoutePointView.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/22/24.
//

import UIKit

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
            addressLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 8),
            addressLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            
        ])
    }
}


class MapMarkerView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing the marker
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Define the marker shape
        let circleRadius = rect.width / 2
        let triangleHeight: CGFloat = 20.0
        
        // Draw the circle
        context.setFillColor(UIColor.red.cgColor)
        context.addEllipse(in: CGRect(x: 0, y: 0, width: rect.width, height: rect.height - triangleHeight))
        context.fillPath()
        
        // Draw the triangle
        context.beginPath()
        context.move(to: CGPoint(x: rect.width / 2, y: rect.height))
        context.addLine(to: CGPoint(x: rect.width, y: rect.height - triangleHeight))
        context.addLine(to: CGPoint(x: 0, y: rect.height - triangleHeight))
        context.closePath()
        context.fillPath()
        
        // Draw the text
        let text = "arrival"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.white
        ]
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(x: (rect.width - textSize.width) / 2,
                              y: (rect.height - triangleHeight - textSize.height) / 2,
                              width: textSize.width,
                              height: textSize.height)
        text.draw(in: textRect, withAttributes: attributes)
    }
}
