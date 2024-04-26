//
//  RouteViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/8/24.
//

import UIKit

// TODO: 컬렉션 뷰 완성 (이번엔 configuration 사용하지 않고 만들어보자..)

final class RouteViewController: UIViewController {
    
    // MARK: - UI Properties
    
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
    
    // TODO: 텍스트 필드일 필요가 없을 수 있겠다.
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
        button.setImage(.backButton, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private var xButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.xButton, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private var stackViewUnderLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        
        return view
    }()
    
    private lazy var routeCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    // MARK: - SearchDataSource
    
    typealias SearchDataSource = UICollectionViewDiffableDataSource<Section, SearchDataModel>
    typealias HistoryCellRegistration = UICollectionView.CellRegistration<SearchHistoryCollectionViewCell, SearchDataModel>
    
    private var historyCellRegistration: HistoryCellRegistration!
    private var searchDataSource: SearchDataSource!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attachView()
        configureSearchDataSource()
        setConstraints()
        setAction()
        
        let departure = UserDefaults.standard.string(forKey: "departure")
        let arrival = UserDefaults.standard.string(forKey: "arrival")
        departureTextField.text = departure
        arrivalTextField.text = arrival
        
        
        routeCollectionView.delegate = self

    }
    
    private func attachView() {
        self.view.backgroundColor = .white
        self.view.addSubview(tradeButton)
        self.view.addSubview(textFieldStackView)
        self.view.addSubview(xButton)
        self.view.addSubview(routeCollectionView)
        self.view.addSubview(stackViewUnderLineView)
    }
    
    private func setAction() {
        // tradeButton.addTarget(self, action: #selector(touchedBackButton), for: .touchUpInside)
        xButton.addTarget(self, action: #selector(touchedXButton), for: .touchUpInside)
        departureTextField.addTarget(self, action: #selector(touchedDirectionTextField), for: .touchDown)
        arrivalTextField.addTarget(self, action: #selector(touchedDirectionTextField), for: .touchDown)
    }
    
    @objc
    private func touchedDirectionTextField() {
        let searchViewController = SearchViewController()
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    @objc
    private func touchedXButton() {
        self.navigationController?.popToRootViewController(animated: false)
    }
}

// MARK: - Configure DataSource

extension RouteViewController {
    
    private func configureSearchDataSource() {
        
        searchDataSource = SearchDataSource(collectionView: routeCollectionView) { (collectionView, indexPath, identifier) -> UICollectionViewCell in
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "routeCell", for: indexPath)
            
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension RouteViewController: UICollectionViewDelegate {
    
    // 검색기록 선택했을 때 빈 곳에 자동으로 채워주기?
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snapshot = searchDataSource.snapshot()
        let histories = snapshot.itemIdentifiers
//        updateHistory(dataIndex: indexPath.row)
        // 1. 셀 title을 빈 textField에 채우기
        if departureTextField.text!.isEmpty {
            departureTextField.text = histories[indexPath.row].title
        } else {
            arrivalTextField.text = histories[indexPath.row].title
        }
        // 2. 다 채워졌을 경우 collectionView의 셀을 길찾기 cell로 변경
    }
}

// MARK: - Layout (Constraints etc..)

extension RouteViewController {
    
    private func setConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tradeButton.centerYAnchor.constraint(equalTo: textFieldStackView.centerYAnchor),
            tradeButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            tradeButton.widthAnchor.constraint(equalToConstant: 12),
            tradeButton.heightAnchor.constraint(equalToConstant: 12),
            
            textFieldStackView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            textFieldStackView.leadingAnchor.constraint(equalTo: tradeButton.trailingAnchor, constant: 8),
            textFieldStackView.trailingAnchor.constraint(equalTo: xButton.leadingAnchor, constant: -8),
            textFieldStackView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.08),
            
            xButton.centerYAnchor.constraint(equalTo: departureTextField.centerYAnchor),
            xButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            xButton.widthAnchor.constraint(equalToConstant: 12),
            xButton.heightAnchor.constraint(equalToConstant: 12),
            
            stackViewUnderLineView.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 8),
            stackViewUnderLineView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            stackViewUnderLineView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            stackViewUnderLineView.heightAnchor.constraint(equalToConstant: 1),
            
            routeCollectionView.topAnchor.constraint(equalTo: stackViewUnderLineView.bottomAnchor),
            routeCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            routeCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            routeCollectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            
        ])
    }
}
