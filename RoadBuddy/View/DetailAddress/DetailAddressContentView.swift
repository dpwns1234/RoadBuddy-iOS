//
//  DetailAddressContentView.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/22/24.
//

import UIKit

final class DetailAddressContentView: UIView, UIContentView {
    private lazy var leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(addressLabel)
        stackView.spacing = 4
        
        return stackView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    private var addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .lightGray
        
        return label
    }()
    
    private lazy var rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.addArrangedSubview(categoryLabel)
        stackView.addArrangedSubview(distanceLabel)
        stackView.alignment = .trailing
        
        return stackView
    }()
    
    private var categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        
        return label
    }()
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        
        return label
    }()
    
    var configuration: UIContentConfiguration {
        didSet {
            apply(configuration: configuration)
        }
    }
    
    init(configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        self.addSubview(leftStackView)
        self.addSubview(rightStackView)
        
        setConstraints()
        apply(configuration: configuration)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            leftStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            leftStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            
            rightStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            rightStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: 이거 어케 없애눙..ㅠㅠ
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 80)
    }
    
    private func apply(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? DetailAddressConfiguration else { return }
        self.titleLabel.text = configuration.title
        self.addressLabel.text = configuration.address
        self.categoryLabel.text = configuration.category
        self.distanceLabel.text = "\(String(describing: configuration.distance))km"
    }
}
