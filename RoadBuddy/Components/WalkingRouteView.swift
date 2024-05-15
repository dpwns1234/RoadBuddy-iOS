//
//  WalkingRouteView.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/15/24.
//

import UIKit

final class WalkingRouteView: UIView {
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .gray
        
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: font.pointSize)
        
        return label
    }()
    
    private var lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        
        return view
    }()
    
    init(step: Step) {
        super.init(frame: .zero)

        backgroundColor = .white
        self.addSubview(distanceLabel)
        self.addSubview(durationLabel)
        self.addSubview(lineView)
        
        bind(data: step)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind(data step: Step) {
        distanceLabel.text = "도보 \(step.distance.text)"
        durationLabel.text = step.duration.text
    }
    
    private func setConstraints() {
        let safeArea = self.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            distanceLabel.topAnchor.constraint(equalTo: safeArea.topAnchor),
            distanceLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            
            durationLabel.topAnchor.constraint(equalTo: safeArea.topAnchor),
            durationLabel.leadingAnchor.constraint(equalTo: distanceLabel.trailingAnchor, constant: 8),
            
            lineView.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 8),
            lineView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            
        ])
    }
}
