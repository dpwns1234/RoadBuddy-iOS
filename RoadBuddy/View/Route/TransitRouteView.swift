//
//  TransitRouteView.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/14/24.
//

import UIKit

final class TransitRouteView: UIView {
    private let shortNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let font = UIFont.preferredFont(forTextStyle: .title3)
        label.font = .boldSystemFont(ofSize: font.pointSize)
        
        return label
    }()
    
    private let departureStopLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    let arrivalStopLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    private let numStopsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .gray
        
        return label
    }()
    
    let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let font = UIFont.preferredFont(forTextStyle: .body)
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
        self.addSubview(shortNameLabel)
        self.addSubview(departureStopLabel)
        self.addSubview(arrivalStopLabel)
        self.addSubview(numStopsLabel)
        self.addSubview(durationLabel)
        self.addSubview(lineView)
        self.addSubview(verticalStepLineView)
        
        bind(data: step)
        setConstraints()
    }
    
    private func bind(data step: Step) {
        guard let transitDetails = step.transitDetails else {
            print("transitDetails is nil!")
            return
        }
        
        let color = step.transitDetails!.line.color
        shortNameLabel.textColor = UIColor(hex: color)
        shortNameLabel.text = "\(transitDetails.line.shortName) 이동"
        departureStopLabel.text = "\(transitDetails.departureStop.name) 승차 (\(transitDetails.departureTime.text))"
        arrivalStopLabel.text = "\(transitDetails.arrivalStop.name) 하차 (\(transitDetails.arrivalTime.text))"
        numStopsLabel.text = "\(transitDetails.numStops)개 이동"
        durationLabel.text = "\(step.duration.text)"
        verticalStepLineView.backgroundColor = UIColor(hex: color)
    }
    
    private func setConstraints() {
        let safeArea = self.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            verticalStepLineView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            verticalStepLineView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            verticalStepLineView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            verticalStepLineView.widthAnchor.constraint(equalToConstant: 8),
            
            shortNameLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            shortNameLabel.leadingAnchor.constraint(equalTo: verticalStepLineView.trailingAnchor, constant: 16),
            
            departureStopLabel.topAnchor.constraint(equalTo: shortNameLabel.bottomAnchor, constant: 16),
            departureStopLabel.leadingAnchor.constraint(equalTo: shortNameLabel.leadingAnchor),
            
            arrivalStopLabel.topAnchor.constraint(equalTo: departureStopLabel.bottomAnchor, constant: 8),
            arrivalStopLabel.leadingAnchor.constraint(equalTo: shortNameLabel.leadingAnchor),
            
            numStopsLabel.topAnchor.constraint(equalTo: arrivalStopLabel.bottomAnchor, constant: 8),
            numStopsLabel.leadingAnchor.constraint(equalTo: shortNameLabel.leadingAnchor),
            
            durationLabel.topAnchor.constraint(equalTo: arrivalStopLabel.bottomAnchor, constant: 8),
            durationLabel.leadingAnchor.constraint(equalTo: numStopsLabel.trailingAnchor, constant: 8),
            
            lineView.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 8),
            lineView.leadingAnchor.constraint(equalTo: shortNameLabel.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
