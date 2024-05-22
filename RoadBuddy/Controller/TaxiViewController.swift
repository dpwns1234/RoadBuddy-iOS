//
//  TaxiViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/22/24.
//

import UIKit

final class TaxiViewController: UIViewController {
    
    private let taxiImageView: UIImageView = {
        let imageView = UIImageView(image: .taxi)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var totalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.layer.borderColor = UIColor.green.cgColor
        stackView.layer.cornerRadius = 8
        stackView.layer.borderWidth = 1
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30)
        
        stackView.addArrangedSubview(mainStackView)
        stackView.addArrangedSubview(middleLine)
        stackView.addArrangedSubview(subStackView)
        
        return stackView
    }()
    
    private let middleLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        view.widthAnchor.constraint(equalToConstant: 120).isActive = true
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 32
        
        let main1 = createVerticalStackView(title: "전체 대기", value: "8", unit: "명")
        let main2 = createVerticalStackView(title: "주변 대기", value: "3", unit: "명")
        let main3 = createVerticalStackView(title: "평균배차대기", value: "8", unit: "분")
        
        stackView.addArrangedSubview(main1)
        stackView.addArrangedSubview(main2)
        stackView.addArrangedSubview(main3)
        
        return stackView
    }()
    
    private lazy var subStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 32
        stackView.alignment = .center
        
        let sub1 = createVerticalStackView(title: "소요 시간", value: "17", unit: "분")
        let sub2 = createVerticalStackView(title: "요금", value: "2,500", unit: "원")
        stackView.addArrangedSubview(sub1)
        stackView.addArrangedSubview(sub2)
        
        return stackView
    }()
    
    private lazy var callButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("바로콜 신청하기", for: .normal)
        button.tintColor = .white
        button.backgroundColor = Hansung.darkBlue.color
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        return button
    }()
    
    func createVerticalStackView(title: String, value: String, unit: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        
        let titleFont = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize)
        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .body)
        
        let valueLabel = UILabel()
        let attributedString = NSMutableAttributedString(string: value+unit)
        attributedString.addAttribute(.font, value: titleFont, range: NSRange(0..<value.count))
        attributedString.addAttribute(.font, value: bodyFont, range: NSRange(value.count..<value.count+unit.count))
        valueLabel.attributedText = attributedString
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
        
        return stackView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(taxiImageView)
        self.view.addSubview(totalStackView)
        self.view.addSubview(callButton)
        
        setConstraints()
    }
    
    private func setConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            taxiImageView.bottomAnchor.constraint(equalTo: mainStackView.topAnchor),
            taxiImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            taxiImageView.widthAnchor.constraint(equalToConstant: 180),
            taxiImageView.heightAnchor.constraint(equalToConstant: 180),
            
            totalStackView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            totalStackView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
            callButton.topAnchor.constraint(equalTo: totalStackView.bottomAnchor, constant: 48),
            callButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
        ])
    }
}
