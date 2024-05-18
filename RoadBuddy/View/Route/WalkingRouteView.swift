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
    
    private var verticalStepLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        return view
    }()
    
    init(step: Step) {
        super.init(frame: .zero)
        
        backgroundColor = .white
        self.addSubview(distanceLabel)
        self.addSubview(durationLabel)
        self.addSubview(lineView)
        self.addSubview(verticalStepLineView)
        
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
            verticalStepLineView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            verticalStepLineView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            verticalStepLineView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            verticalStepLineView.widthAnchor.constraint(equalToConstant: 8),
            
            distanceLabel.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            distanceLabel.leadingAnchor.constraint(equalTo: verticalStepLineView.trailingAnchor, constant: 16),
            
            durationLabel.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            durationLabel.leadingAnchor.constraint(equalTo: distanceLabel.trailingAnchor, constant: 8),
            
            lineView.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 8),
            lineView.leadingAnchor.constraint(equalTo: distanceLabel.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
}
