//
//  SearchViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/17/24.
//

import UIKit


// TODO: (1) 한 섹션은 연관검색어, (2) 그 아래 섹션은 검색 결과(자세한 주소 정보까지 나오는 셀)
final class SearchViewController: UIViewController {
    private var backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "direction_off")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return button
    }()
    
    private var searchTextField: UITextField = {
        let textField = FilterTextField(content: "Seach the place", backgroundColor: .white)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var searchHistoryCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    typealias SearchHistoryDataSource = UICollectionViewDiffableDataSource<Int, SearchHistory> // TODO: Section으로 구분?
    typealias SearchHistoryCellRegistration = UICollectionView.CellRegistration<SearchHistoryCollectionViewCell, SearchHistory>
    
    private var dataSource: SearchHistoryDataSource!
    private var cellRegistration: SearchHistoryCellRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(backButton)
        self.view.addSubview(searchTextField)
        self.view.addSubview(searchHistoryCollectionView)
        
        configureDataSource()
        setConstraints()
    }
    
    private func setConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            
            searchTextField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            searchTextField.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            
            // TODO: 라인 하나 그으던가, 아니면 그림자 표시 하던가
            searchHistoryCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: -8),
            searchHistoryCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            searchHistoryCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            searchHistoryCollectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            
        ])
    }
    
    private func configureDataSource() {
        cellRegistration = SearchHistoryCellRegistration { (cell, indexPath, item) in
            cell.item = item
        }
        
        dataSource = SearchHistoryDataSource(collectionView: searchHistoryCollectionView) { (collectionView, indexPath, identifier) -> UICollectionViewListCell in
            collectionView.allowsSelection = false
            return collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: identifier)
        }
        
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems([SearchHistory(title: "가산디지털", created: Date())])
        snapshot.appendItems([SearchHistory(title: "가산디지털2", created: Date())])
        dataSource.apply(snapshot)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 70)
    }
}
