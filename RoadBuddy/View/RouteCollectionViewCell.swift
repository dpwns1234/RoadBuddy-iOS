//
//  RouteCollectionViewCell.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/26/24.
//

import UIKit

final class RouteCollectionViewCell: UICollectionViewCell {
    static let identifier = "routeCell"
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.addArrangedSubview(stepStackView)
        stackView.addArrangedSubview(estimatedTimeLabel)
        
        return stackView
    }()
    
    private lazy var stepStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 4
        
        return stackView
    }()
    
    private var estimatedTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .black
        
        return label
    }()
    
    private var durationTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title2)
        label.textColor = .black
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        return label
    }()
    
    private let bottomLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .white
        
        self.addSubview(verticalStackView)
        self.addSubview(durationTimeLabel)
        self.addSubview(bottomLineView)
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ route: Route) {
        let steps = route.legs[0].steps
        for i in 0..<steps.count {
            let step = steps[i]
            if step.travelMode == TravelType.walking.description {
                let duration = step.duration.value
                createWalkingStep(duration, perioty: i)
            } else {
                guard let transit = step.transitDetails else { return }
                bindStepLabel(data: transit, perioty: i)
            }
            
            if step != steps.last {
                createRightDirectionView(perioty: i)
            }
        }
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "a h:mm" // 2020.08.13 오후 4시 30분
        myDateFormatter.locale = Locale(identifier:"ko_KR") // PM, AM을 언어에 맞게 setting (ex: PM -> 오후)
        
        let departureTimestamp: TimeInterval = TimeInterval(route.legs[0].departureTime.value)
        let arrivalTimestamp: TimeInterval = TimeInterval(route.legs[0].arrivalTime.value)
        
        let departureDate = Date(timeIntervalSince1970: (departureTimestamp))
        let arrivalDate = Date(timeIntervalSince1970: (arrivalTimestamp))

        let departureStr = myDateFormatter.string(from: departureDate)
        let arrivalStr = myDateFormatter.string(from: arrivalDate)
        
        durationTimeLabel.text = route.legs[0].duration.text
        estimatedTimeLabel.text = "\(departureStr) - \(arrivalStr)"
    }
    
    private func createStepLabel() -> UIPaddingLabel {
        let stepLabel = UIPaddingLabel()
        stepLabel.clipsToBounds = true
        stepLabel.layer.cornerRadius = 4
        stepLabel.padding = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        
        return stepLabel
    }
    
    // TODO: 1호선은 1만 나옴.. 다른 호선들도 확인할 수 있음 확인 하기.
    // TODO: 갑자기 leg가 nil, color가 nil나와서 안 됐던 적 있음
    private func createWalkingStep(_ duration: Int, perioty: Int) {
        let walkingImageView = UIImageView()
        walkingImageView.translatesAutoresizingMaskIntoConstraints = false
        walkingImageView.image = UIImage(named: TravelType.walking.description)
        walkingImageView.contentMode = .scaleAspectFit
        walkingImageView.center = center
        walkingImageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 450 - Float(perioty)), for: .horizontal)
        
        let durationLabel = UILabel()
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.text = String((duration/60))
        durationLabel.font = .preferredFont(forTextStyle: .footnote)
        durationLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 450 - Float(perioty)), for: .horizontal)
        
        let walkingView = UIView()
        walkingView.translatesAutoresizingMaskIntoConstraints = false
        walkingView.addSubview(walkingImageView)
        walkingView.addSubview(durationLabel)
        walkingView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 450 - Float(perioty)), for: .horizontal)
        
        NSLayoutConstraint.activate([
            walkingImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 28),
            walkingImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 28),
            walkingImageView.topAnchor.constraint(equalTo: walkingView.topAnchor),
            walkingImageView.bottomAnchor.constraint(equalTo: walkingView.bottomAnchor),
            walkingImageView.leadingAnchor.constraint(equalTo: walkingView.leadingAnchor),
            
            durationLabel.leadingAnchor.constraint(equalTo: walkingImageView.trailingAnchor),
            durationLabel.bottomAnchor.constraint(equalTo: walkingView.bottomAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: walkingView.trailingAnchor)
        ])
        
        stepStackView.addArrangedSubview(walkingView)
    }
    
    private func createRightDirectionView(perioty: Int) {
        let directionView = UIImageView()
        directionView.translatesAutoresizingMaskIntoConstraints = false
        directionView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        directionView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        directionView.image = UIImage(named: "right_direction")
        directionView.contentMode = .scaleAspectFit
        directionView.center = center
        directionView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 450 - Float(perioty)), for: .horizontal)
        
        stepStackView.addArrangedSubview(directionView)
    }
    
    private func bindStepLabel(data transit: Transit, perioty: Int) {
        let title = transit.line.shortName
        let textColor = transit.line.textColor
        let backgroundColor = transit.line.color
        let stepLabel = createStepLabel()
        stepLabel.textColor = UIColor(hex: textColor)
        stepLabel.backgroundColor = UIColor(hex: backgroundColor)
        stepLabel.text = title
        stepLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 450 - Float(perioty)), for: .horizontal)
        
        stepStackView.addArrangedSubview(stepLabel)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            verticalStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            verticalStackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.75),
            
            durationTimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            durationTimeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            bottomLineView.heightAnchor.constraint(equalToConstant: 0.5),
            bottomLineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
