//
//  SearchHistoryContentView.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/18/24.
//

import UIKit

final class SearchHistoryContentView: UIView, UIContentView {
    private var titleLabel: UILabel = {
        let textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .preferredFont(forTextStyle: .callout)
        textView.textColor = .black
        
        return textView
    }()
    
    private var createdLabel: UILabel = {
        let textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .preferredFont(forTextStyle: .caption2)
        textView.textColor = .lightGray
        
        return textView
    }()
    
    var removeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 12).isActive = true
        button.heightAnchor.constraint(equalToConstant: 12).isActive = true
        button.setImage(.xButton, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .center
        
        return button
    }()
    
    var removeAction: (() -> Void)?
    
    var configuration: UIContentConfiguration {
        didSet {
            apply(configuration: configuration)
        }
    }
    
    // TODO: chatBot에선 이런거 안 썼어도 됐는데ㅠㅠㅠ 왜 여기선 써야하지..?
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 40)
    }
    
    init(configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        addSubview(titleLabel)
        addSubview(createdLabel)
        addSubview(removeButton)
        
        setConstraints()
        apply(configuration: configuration)
        removeButton.addTarget(self, action: #selector(removeHistory), for: .touchUpInside)
    }
    
    @objc
    private func removeHistory() {
        removeAction?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -8),
            
            createdLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -8),
            createdLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            createdLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -8),
            
            removeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            removeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            removeButton.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -8),

        ])
    }
    
    func apply(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? SearchHistoryConfiguration else { return }
        removeAction = configuration.removeAction
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd."
        
        self.titleLabel.text = configuration.title
        self.createdLabel.text = dateFormatter.string(from: configuration.created!)
    }
}
