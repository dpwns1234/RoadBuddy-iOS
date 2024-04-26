//
//  RouteCollectionViewCell.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/26/24.
//

import UIKit

final class RouteCollectionViewCell: UICollectionViewCell {
    static let identifier = "routeCell"
    
    private lazy var stepStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        return stackView
    }()
    
    private var estimatedTimeLabel: UIPaddingLabel = {
        let label = UIPaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .black
        label.text = "오후 2:00 - 오후 2:58"
        
        return label
    }()
    
    private var durationTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .black
        label.text = "58분"
        label.layer.cornerRadius = 16
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .white
        
        self.addSubview(stepStackView)
        self.addSubview(estimatedTimeLabel)
        self.addSubview(durationTimeLabel)
        
        setConstraints()
    }
    
    //
    //    required init?(coder: NSCoder) {
    //        super.init(coder: coder)
    //        self.contentView.backgroundColor = .white
    //    }
    //
    //    override func layoutSubviews() {
    //        super.layoutSubviews()
    //        layoutTitleLabel()
    //    }
    
    
//    init() {
//        super.init(frame: .zero)
//        
//        self.addSubview(stepStackView)
//        self.addSubview(estimatedTimeLabel)
//        self.addSubview(durationTimeLabel)
//        
//        setConstraints()
//        
//    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ route: Route) {
        //        let steps = route.legs?[0].steps
        let stepsCount = 2
        for i in 0..<stepsCount {
            let step = createStepLabel(i)
            stepStackView.addArrangedSubview(step)
        }
    }
    
    // TODO: 오른쪽 가리키는 이미지도 중간에 넣어주기 및 binding
    private func createStepLabel(_ i: Int) -> UIPaddingLabel {
        let stepLabel = UIPaddingLabel()
        stepLabel.backgroundColor = .blue
        stepLabel.textColor = .red
        stepLabel.text = "test-\(i)"
        stepLabel.clipsToBounds = true
        stepLabel.layer.cornerRadius = 4
        stepLabel.padding = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        return stepLabel
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            stepStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            stepStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
            stepStackView.trailingAnchor.constraint(equalTo: durationTimeLabel.leadingAnchor, constant: -8),
            
            estimatedTimeLabel.topAnchor.constraint(equalTo: stepStackView.bottomAnchor, constant: 8),
            estimatedTimeLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
            
            durationTimeLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            durationTimeLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
        ])
    }
}
