//
//  RouteViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/8/24.
//

import UIKit

// TODO: UserDefault로 검색 주소 위경도로 서치하기

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
        button.setImage(.trade, for: .normal)
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
        collectionView.delegate = self
        collectionView.register(RouteCollectionViewCell.self, forCellWithReuseIdentifier: RouteCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    // MARK: - SearchDataSource
    
    typealias RouteDataSource = UICollectionViewDiffableDataSource<Int, Route>
    private var routeDataSource: RouteDataSource!
    
    private let dataService = DirectionDataService()
    private var direcionData: Direction? = nil
    
    private let addressRepository = UserDefaultRepository<Address>()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attachView()
        configureSearchDataSource()
        setConstraints()
        setAction()
        dataService.delegate = self
        let departure = addressRepository.fetch(type: "departure")
        let arrival = addressRepository.fetch(type: "arrival")
//        let departure = UserDefaults.standard.string(forKey: "departure")
//        let arrival = UserDefaults.standard.string(forKey: "arrival")
        departureTextField.text = departure?.title
        arrivalTextField.text = arrival?.title
        if (departure?.title.isEmpty != nil) && (arrival?.title.isEmpty != nil) {
            findRoute()
        }
    }
    
    private func findRoute() {
        // API call
        dataService.convertData(type: .direction(departureLat: 37.51891897875439, departureLon: 126.895693752969, arrivalLat: 37.5548376, arrivalLon: 126.9717326))
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
        UserDefaults.standard.removeObject(forKey: "departure")
        UserDefaults.standard.removeObject(forKey: "arrival")
        self.navigationController?.popToRootViewController(animated: false)
    }
}

// MARK: - Configure DataSource

extension RouteViewController {
    
    private func configureSearchDataSource() {
        routeDataSource = RouteDataSource(collectionView: routeCollectionView) { (collectionView, indexPath, identifier) -> UICollectionViewCell in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RouteCollectionViewCell.identifier, for: indexPath) as? RouteCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(identifier)
            return cell
        }
        
        var snapshot = routeDataSource.snapshot()
        snapshot.appendSections([0])
        routeDataSource.apply(snapshot)
    }
}

// MARK: - UICollectionViewDelegate

extension RouteViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snapshot = routeDataSource.snapshot()
        let routes = snapshot.itemIdentifiers
        let selectRoute = routes[indexPath.row]
        displayBottomSheet(data: selectRoute)
    }
    
    private func displayBottomSheet(data selectRoute: Route) {
        let bottomVC = BottomSheetViewController(route: selectRoute)
        if let sheet = bottomVC.sheetPresentationController {
            sheet.detents = [.large(), .medium()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
        }
        
        present(bottomVC, animated: true)
    }
}

//extension RouteViewController: SearchResultDelegate {
//    
//    func moveRouteVC() {
//        <#code#>
//    }
//}

// MARK: - DirectionDataServiceDelegate

extension RouteViewController: DirectionDataServiceDelegate {
    func directionDataService(_ service: DirectionDataService, didDownlad: Direction) {
        self.direcionData = didDownlad
        
        var snapshot = routeDataSource.snapshot()
        snapshot.appendItems(didDownlad.data.routes)
        routeDataSource.apply(snapshot)
    }
}

// MARK: - Layout (Constraints etc..)

extension RouteViewController {
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.15))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
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
