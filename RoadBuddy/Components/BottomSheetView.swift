//
//  BottomSheetView.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/28/24.
//

import UIKit

final class BottomSheetView: UIView {
    private var titleLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.preferredFont(forTextStyle: .body)
        let boldFont = UIFont.boldSystemFont(ofSize: font.pointSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = boldFont
        label.textColor = Hansung.blue.color
        label.numberOfLines = 0
        
        return label
    }()
    
    private var categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = .lightGray
        label.numberOfLines = 0
        
        return label
    }()
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.preferredFont(forTextStyle: .caption2)
        let boldFont = UIFont.boldSystemFont(ofSize: font.pointSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = boldFont
        // bold처리
        label.numberOfLines = 0
        
        return label
    }()
    
    private var addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption2)
        label.numberOfLines = 0
        
        return label
    }()
    
    private var lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.addArrangedSubview(startingButton)
        stackView.addArrangedSubview(destinationButton)
        
        return stackView
    }()
    
    private let startingButton: UIButton = {
        let button = MainButton(status: .off, titleText: "출발")
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let destinationButton: UIButton = {
        let button = MainButton(status: .on, titleText: "도착")
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private init() {
        super.init(frame: .zero)
    }
    
    init(model: SearchDataModel) {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        titleLabel.text = model.title
        categoryLabel.text = model.category
        distanceLabel.text = "\(model.distance!)"
        addressLabel.text = model.address
        
        self.addSubview(titleLabel)
        self.addSubview(categoryLabel)
        self.addSubview(distanceLabel)
        self.addSubview(addressLabel)
        self.addSubview(lineView)
        self.addSubview(buttonStackView)
        self.layer.cornerRadius = 30
        
        setConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints() {
        let safeArea = self.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            
            categoryLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 4),
            categoryLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            
            distanceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            distanceLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            
            addressLabel.topAnchor.constraint(equalTo: distanceLabel.topAnchor),
            addressLabel.leadingAnchor.constraint(equalTo: distanceLabel.trailingAnchor, constant: 16),
            
            lineView.heightAnchor.constraint(equalToConstant: 0.5),
            lineView.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 24),
            lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            buttonStackView.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 8),
            buttonStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            buttonStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            
        ])
    }
}
