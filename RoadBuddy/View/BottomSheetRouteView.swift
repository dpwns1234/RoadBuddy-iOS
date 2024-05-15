//
//  BottomSheetRouteView.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/8/24.
//

import UIKit

final class BottomSheetRouteView: UIView {
    
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
        stackView.spacing = 8
        stackView.backgroundColor = .white
        
        return stackView
    }()
    
//    private let scrollView: UIScrollView = {    
//        let scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        
//        return scrollView
//    }()

    
    init(route: Route) {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        self.addSubview(durationTimeLabel)
        self.addSubview(arrivalTimeLabel)
        self.addSubview(routeLineStackView)
        self.addSubview(routeDetailStackView)
        self.layer.cornerRadius = 30
        
        bind(route: route)
        configureRouteLineStackView(route: route)
        addRouteDetailView(route.legs[0].steps)
        setConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind(route: Route) {
        durationTimeLabel.text = route.legs[0].duration.text
        arrivalTimeLabel.text = "\(route.legs[0].arrivalTime.text) 도착"
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
            
            routeDetailStackView.topAnchor.constraint(equalTo: routeLineStackView.bottomAnchor, constant: 16),
            routeDetailStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            routeDetailStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            
            
            
//            routeDetailStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            routeDetailStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            routeDetailStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            routeDetailStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            routeDetailStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor), // 스크롤 방향에 맞게 가로 크기 설정
//            
//            scrollView.topAnchor.constraint(equalTo: routeLineStackView.bottomAnchor, constant: 8),
//            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}

// MARK: - RouteLine (경로 상단에 요약해놓은 Route line)

extension BottomSheetRouteView {
    
    private func configureRouteLineStackView(route: Route) {
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
            
            if step.travelMode == TravelType.walking.description {
                lineView = createStepLineView(durationPercent: percent, color: .gray, transitType: step.travelMode)
            } else {
                let colorCode = step.transitDetails!.line.color
                let color = UIColor(hex: colorCode)
                let type = step.transitDetails!.line.vehicle.type
                lineView = createStepLineView(durationPercent: percent, color: color!, transitType: type)
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
}

// MARK: - RouteDetail (경로 vertical)

extension BottomSheetRouteView {
    
    private func addRouteDetailView(_ steps: Array<Step>) {
        for step in steps {
            if step.travelMode == TravelType.walking.description {
                let walkingRouteView = WalkingRouteView(step: step)
                routeDetailStackView.addArrangedSubview(walkingRouteView)
            } else {
                let transitRouteView = TransitRouteView(step: step)
                routeDetailStackView.addArrangedSubview(transitRouteView)
            }
        }
    }
    
    private func createWalkingRouteView(step: Step) -> UIStackView {
        let stackView = UIStackView()
        let distanceLabel = UILabel()
        let durationLabel = UILabel()
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        let font = UIFont.preferredFont(forTextStyle: .body)
        distanceLabel.textColor = .gray
        distanceLabel.font = font
        durationLabel.font = .boldSystemFont(ofSize: font.pointSize)
        
        distanceLabel.text = "도보 \(step.distance.text)"
        durationLabel.text = step.duration.text
        
        stackView.addArrangedSubview(distanceLabel)
        stackView.addArrangedSubview(durationLabel)
        
        return stackView
    }
}
