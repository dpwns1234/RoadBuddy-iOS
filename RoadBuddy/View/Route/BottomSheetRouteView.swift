//
//  BottomSheetRouteView.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/8/24.
//

import UIKit

final class BottomSheetRouteView: UIView {
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.layer.cornerRadius = 30
        
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        return view
    }()
    
    private var durationTimeLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.preferredFont(forTextStyle: .title2)
        let boldFont = UIFont.boldSystemFont(ofSize: font.pointSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = boldFont
        label.textColor = .black
        
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
    
    init(leg: Leg) {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(durationTimeLabel)
        contentView.addSubview(arrivalTimeLabel)
        contentView.addSubview(routeLineStackView)
        contentView.addSubview(routeDetailStackView)
        self.layer.cornerRadius = 30
        bind(leg: leg)
        configureRouteLineStackView(leg: leg)
        addRouteDetailView(leg)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind(leg: Leg) {
        durationTimeLabel.text = leg.duration.text
        arrivalTimeLabel.text = "\(leg.arrivalTime.text) 도착"
    }
    
    private func setConstraints() {
        let safeArea = self.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            durationTimeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            durationTimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            arrivalTimeLabel.centerYAnchor.constraint(equalTo: durationTimeLabel.centerYAnchor),
            arrivalTimeLabel.leadingAnchor.constraint(equalTo: durationTimeLabel.trailingAnchor, constant: 12),
            
            routeLineStackView.topAnchor.constraint(equalTo: durationTimeLabel.bottomAnchor, constant: 16),
            routeLineStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            routeLineStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            routeLineStackView.heightAnchor.constraint(equalToConstant: 30),
            
            routeDetailStackView.topAnchor.constraint(equalTo: routeLineStackView.bottomAnchor, constant: 16),
            routeDetailStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            routeDetailStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            routeDetailStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
            
        ])
    }
}

// MARK: - RouteLine (경로 상단에 요약해놓은 Route line)

extension BottomSheetRouteView {
    
    private func configureRouteLineStackView(leg: Leg) {
        let steps = leg.steps
        let ratioArray = calculateWidthRatio(leg: leg)
        for i in steps.indices {
            let step = steps[i]
            var lineView: UIView
            
            if step.travelMode == TravelType.walking.description {
                lineView = createStepLineView(durationPercent: ratioArray[i], color: .gray, transitType: step.travelMode)
            } else {
                let colorCode = step.transitDetails!.line.color
                let color = UIColor(hex: colorCode)
                let type = step.transitDetails!.line.vehicle.type
                lineView = createStepLineView(durationPercent: ratioArray[i], color: color!, transitType: type)
            }
            routeLineStackView.addArrangedSubview(lineView)
        }
    }
    
    private func calculateWidthRatio(leg: Leg) -> [Double] {
        var ratioArray = [Double]()
        let totalDuration = Double(leg.duration.value)
        var maxRatio = 0.0
        var maxRatioIndex = 0
        for (index, step) in leg.steps.enumerated() {
            let duration = Double(step.duration.value)
            let ratio = duration / totalDuration
            ratioArray.append(ratio)
            
            if ratio > maxRatio {
                maxRatio = ratio
                maxRatioIndex = index
            }
        }
        
        ratioArray = ratioArray.map { max($0, 0.1) }
        let sum = ratioArray.reduce(0, +)
        var difference = sum - 1
        ratioArray[maxRatioIndex] -= difference
        
        return ratioArray
    }
    
    private func createStepLineView(durationPercent: Double, color: UIColor, transitType: String) -> StepLineView {
        let view = StepLineView(frame: CGRect(x: 0, y: 0, width: routeLineStackView.bounds.width * durationPercent, height: routeLineStackView.bounds.height))
        view.backgroundColor = .white
        view.lineColor = color
        view.image = UIImage(named: transitType)
        routeLineStackView.addArrangedSubview(view)
        view.widthAnchor.constraint(equalTo: routeLineStackView.widthAnchor, multiplier: durationPercent).isActive = true
        
        return view
    }
}

// MARK: - RouteDetail (vertical 경로)

extension BottomSheetRouteView {
    
    private func addRouteDetailView(_ leg: Leg) {
        // 출발
        let departureLabel = RoutePointView(address: leg.startAddress, color: Hansung.blue.color)
        routeDetailStackView.addArrangedSubview(departureLabel)
        
        for step in leg.steps {
            if step.travelMode == TravelType.walking.description {
                travelModeIsWalking(step: step)
            } else {    // 지하철, 버스
                let transitRouteView = TransitRouteView(step: step)
                routeDetailStackView.addArrangedSubview(transitRouteView)
            }
        }
        
        // 도착
        let arrivalLabel = RoutePointView(address: leg.endAddress, color: .red)
        routeDetailStackView.addArrangedSubview(arrivalLabel)
    }
    
    private func travelModeIsWalking(step: Step) {
        if  // 환승
            let transferPath = step.transferPath,
            transferPath.isEmpty == false 
        {
            let transferRouteView = TransferRouteView(transferPath: transferPath[0])
            routeDetailStackView.addArrangedSubview(transferRouteView)
        } else {    // 도보
            let walkingRouteView = WalkingRouteView(step: step)
            routeDetailStackView.addArrangedSubview(walkingRouteView)
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
