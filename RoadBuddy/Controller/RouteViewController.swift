//
//  RouteViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/8/24.
//

import UIKit

final class RouteViewController: UIViewController {
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
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
    
    private let directionDataManager = DirectionDataManager()
    
    private let addressRepository = UserDefaultRepository<Address>()
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(routeCollectionView)
        self.view.addSubview(loadingIndicator)
        configureSearchDataSource()
        setConstraints()
        directionDataManager.delegate = self
        
        let departure = addressRepository.fetch(type: "departure")
        let arrival = addressRepository.fetch(type: "arrival")
        if (departure?.title.isEmpty == false) && (arrival?.title.isEmpty == false) {
            loadingIndicator.startAnimating()
            directionDataManager.fetchDirection(
                departure: departure!.geocoding.addresses[0].locatoin,
                arrival: arrival!.geocoding.addresses[0].locatoin
            )
        }
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
        
        let routeResultViewController = RouteResultViewController(leg: selectRoute.legs[0])
        self.navigationController?.pushViewController(routeResultViewController, animated: true)
    }
}

// MARK: - DirectionDataManagerDelegate

extension RouteViewController: DirectionDataManagerDelegate {
    func directionData(_ dataManager: DirectionDataManager, didLoad direction: Direction) {
        var snapshot = routeDataSource.snapshot()
        snapshot.appendItems(direction.data.routes)
        routeDataSource.apply(snapshot)
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
        }
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
            routeCollectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            routeCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            routeCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            routeCollectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            
            loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
        ])
    }
}
