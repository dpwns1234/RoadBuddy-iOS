//
//  BottomSheetRouteView.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/8/24.
//

import UIKit

final class BottomSheetRouteView: UIView {
    var route: Route?
    
    private var durationTimeLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.preferredFont(forTextStyle: .title2)
        let boldFont = UIFont.boldSystemFont(ofSize: font.pointSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = boldFont
        label.textColor = .black
        label.numberOfLines = 0
        
        return label
    }()
    
    private var arrivalTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .black
        label.numberOfLines = 0
        
        return label
    }()
    
    private var routeLineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.backgroundColor = .white
        
        return stackView
    }()
    
    private lazy var routeDetailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.backgroundColor = .white
        
        return stackView
    }()
    
    init(route: Route?) {
        self.route = route
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        self.addSubview(durationTimeLabel)
        self.addSubview(arrivalTimeLabel)
        self.addSubview(routeLineStackView)
//        self.addSubview(routeDetailStackView)
        self.layer.cornerRadius = 30
        configureRouteLineStackView()
//        configureRouteLineStackView2()
        setConstraints()
    }
    
    private func configureRouteLineStackView2() {
        let count = 2
        for _ in 0..<count {
            var lineView: UIView
            lineView = createStepLineView(durationPercent: 0.4, color: .gray, transitType: "subway")
            routeLineStackView.addArrangedSubview(lineView)
        }
    }
    
    private func bind() {
        durationTimeLabel.text = route?.legs[0].duration.text
        arrivalTimeLabel.text = route?.legs[0].arrivalTime.timeZone
    }

    private func configureRouteLineStackView() {
        guard let route = route else {
            print("route is nil!")
            return
        }
        let steps = route.legs[0].steps
        let totalDuration = Double(route.legs[0].duration.value)
        let standardPercent = 0.1
        var modifyPercent = 0.0
        for step in steps {
            let duration = Double(step.duration.value)
            var percent = duration / totalDuration
            var lineView: UIView
            
            if percent < standardPercent {
                modifyPercent = standardPercent - percent
                percent = standardPercent
            } else if (percent - modifyPercent) > standardPercent {
                percent = percent - modifyPercent
                modifyPercent = 0
            }
            
            if step.travelMode == "WALKING" {
                lineView = createStepLineView(durationPercent: percent, color: .gray, transitType: "subway")
            } else {
                let colorCode = step.transitDetails!.line.color
                let color = UIColor(hex: colorCode)
                lineView = createStepLineView(durationPercent: percent, color: color!, transitType: "bus")
            }
            routeLineStackView.addArrangedSubview(lineView)
        }
    }
    
    private func createStepLineView(durationPercent: Double, color: UIColor, transitType: String) -> StepLineView {
        let view = StepLineView(frame: CGRect(x: 0, y: 0, width: routeLineStackView.bounds.width, height: routeLineStackView.bounds.height))
        view.backgroundColor = .white
        view.lineColor = color
        view.image = UIImage(named: transitType)
        routeLineStackView.addArrangedSubview(view)
        view.widthAnchor.constraint(equalTo: routeLineStackView.widthAnchor, multiplier: durationPercent).isActive = true
        
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createWalkingRouteView() -> UIView {
        let view = UIView()
        
        return view
    }
    
    private func createBusRouteView() -> UIView {
        let view = UIView()
        
        return view
    }
    
    private func createSubwayRouteView() -> UIView {
        let view = UIView()
        
        return view
    }
    
    private func setConstraints() {
        let safeArea = self.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            durationTimeLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            durationTimeLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            
            arrivalTimeLabel.centerYAnchor.constraint(equalTo: durationTimeLabel.centerYAnchor),
            arrivalTimeLabel.leadingAnchor.constraint(equalTo: durationTimeLabel.trailingAnchor, constant: 12),
            
            routeLineStackView.topAnchor.constraint(equalTo: durationTimeLabel.bottomAnchor, constant: 16),
            routeLineStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            routeLineStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            routeLineStackView.heightAnchor.constraint(equalToConstant: 30),
            
        ])
    }
}
