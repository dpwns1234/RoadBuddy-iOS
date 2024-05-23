//
//  TabBarViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/22/24.
//

import UIKit

class TabBarViewController: UIViewController {
    
    // MARK: - UI Properties
    
    var selectedTabIndex: Int = 0
    
    private lazy var textFieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(departureTextField)
        stackView.addArrangedSubview(arrivalTextField)
        stackView.spacing = 4
        
        return stackView
    }()
    
    private var departureTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "출발지"
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = Hansung.lightGrey.color
        textField.addLeftPadding()
        
        return textField
    }()
    
    private var arrivalTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "도착지"
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = Hansung.lightGrey.color
        textField.addLeftPadding()
        
        return textField
    }()
    
    private var tradeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.trade, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private var xButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.xButton, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.widthAnchor.constraint(equalToConstant: 12).isActive = true
        button.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        return button
    }()
    
    private var stackViewUnderLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        
        return view
    }()
    
    private let tabBarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        return stackView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let addressRepository = UserDefaultRepository<Address>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setMain()
        setupTabBar()
        selectTab(at: 0)
        
        let departure = addressRepository.fetch(type: "departure")
        let arrival = addressRepository.fetch(type: "arrival")
        departureTextField.text = departure?.title
        arrivalTextField.text = arrival?.title

    }
    
    func setButtonAction() {
        // tradeButton.addTarget(self, action: #selector(touchedBackButton), for: .touchUpInside)
        xButton.addTarget(self, action: #selector(touchedXButton), for: .touchUpInside)
        departureTextField.addTarget(self, action: #selector(touchedDirectionTextField), for: .touchDown)
        arrivalTextField.addTarget(self, action: #selector(touchedDirectionTextField), for: .touchDown)
    }
    private func setMain() {
        self.view.backgroundColor = .white
        self.view.addSubview(tradeButton)
        self.view.addSubview(xButton)
        self.view.addSubview(textFieldStackView)
        self.view.addSubview(tabBarStackView)
        self.view.addSubview(stackViewUnderLineView)
        self.view.addSubview(containerView)
        
        setButtonAction()
        setConstraints()
    }
    
    @objc
    private func touchedDirectionTextField() {
        let searchViewController = SearchViewController()
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    @objc
    private func touchedXButton() {
        UserDefaults.standard.removeObject(forKey: "departure")
        UserDefaults.standard.removeObject(forKey: "arrival")
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    private func setupTabBar() {
        let tabs = [UIImage(named: "BUS"), UIImage(named: "taxi")]
        for (index, tab) in tabs.enumerated() {
            let button = UIButton()
            button.setImage(tab, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.tag = index
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            button.addTarget(self, action: #selector(tabButtonTapped), for: .touchUpInside)
            tabBarStackView.addArrangedSubview(button)
        }
    }
    
    @objc 
    private func tabButtonTapped(_ sender: UIButton) {
        selectTab(at: sender.tag)
    }
    
    private func selectTab(at index: Int) {
        for child in children {
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
        let selectedViewController: UIViewController
        switch index {
        case 0:
            selectedViewController = RouteViewController()
        case 1:
            selectedViewController = TaxiViewController()
        default:
            return
        }
        
        addChild(selectedViewController)
        containerView.addSubview(selectedViewController.view)
        selectedViewController.view.frame = containerView.bounds
        selectedViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        selectedViewController.didMove(toParent: self)
        
        updateTabButtonAppearance(selectedIndex: index)
    }
    
    private func updateTabButtonAppearance(selectedIndex: Int) {
        UIView.animate(withDuration: 0.3, animations: {
            for (index, view) in self.tabBarStackView.arrangedSubviews.enumerated() {
                if let button = view as? UIButton {
                    if index == selectedIndex {
                        button.backgroundColor = Hansung.skyBlue.color
                        button.transform = CGAffineTransform(translationX: 0, y: 0)
                    } else {
                        button.backgroundColor = .clear
                        // 나머지 버튼들은 원래 위치로
                        button.transform = CGAffineTransform.identity
                    }
                }
            }
        })
    }
}

// MARK: - Set Layout

extension TabBarViewController {
    
    private func setConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tradeButton.centerYAnchor.constraint(equalTo: textFieldStackView.centerYAnchor),
            tradeButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            tradeButton.widthAnchor.constraint(equalToConstant: 12),
            tradeButton.heightAnchor.constraint(equalToConstant: 12),

            xButton.centerYAnchor.constraint(equalTo: departureTextField.centerYAnchor),
            xButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            
            textFieldStackView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            textFieldStackView.leadingAnchor.constraint(equalTo: tradeButton.trailingAnchor, constant: 8),
            textFieldStackView.trailingAnchor.constraint(equalTo: xButton.leadingAnchor, constant: -8),
            textFieldStackView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.08),
            
            tabBarStackView.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 16),
            tabBarStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarStackView.heightAnchor.constraint(equalToConstant: 50),
            
            stackViewUnderLineView.topAnchor.constraint(equalTo: tabBarStackView.bottomAnchor),
            stackViewUnderLineView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            stackViewUnderLineView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            stackViewUnderLineView.heightAnchor.constraint(equalToConstant: 1),
            
            containerView.topAnchor.constraint(equalTo: stackViewUnderLineView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
    }
}
