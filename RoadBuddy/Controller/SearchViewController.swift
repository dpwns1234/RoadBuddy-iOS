//
//  SearchViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/17/24.
//

import UIKit


// TODO: (1) 한 섹션은 연관검색어, (2) 그 아래 섹션은 검색 결과(자세한 주소 정보까지 나오는 셀)
final class SearchViewController: UIViewController {
    private lazy var searchStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(searchTextField)
        stackView.spacing = 24
        
        return stackView
    }()
    
    private var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.backButton, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search the place"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        
        textField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        
        return textField
    }()
    
    private var stackViewUnderLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        
        return view
    }()
    
    private lazy var searchHistoryCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    typealias SearchHistoryDataSource = UICollectionViewDiffableDataSource<Int, SearchHistory> // TODO: Section으로 구분?
    typealias SearchHistoryCellRegistration = UICollectionView.CellRegistration<SearchHistoryCollectionViewCell, SearchHistory>
    
    private let historyRepository = UserDefaultRepository<[SearchHistory]>()
    private var dataSource: SearchHistoryDataSource!
    private var cellRegistration: SearchHistoryCellRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(searchStackView)
        self.view.addSubview(searchHistoryCollectionView)
        self.view.addSubview(stackViewUnderLineView)
        configureDataSource()
        setConstraints()
        
        searchTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        var snapshot = dataSource.snapshot()
        // TODO: 여기서 업데이트를(apply) 안 해줘도 되지 않나?
        let searchHistories = snapshot.itemIdentifiers(inSection: 0)
        snapshot.appendItems(searchHistories, toSection: 0)
        dataSource.apply(snapshot)
    }
    
    private func setConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            searchStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            searchStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            searchStackView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.08),
            
            backButton.centerYAnchor.constraint(equalTo: searchStackView.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: searchStackView.leadingAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 12),
            
            searchTextField.centerYAnchor.constraint(equalTo: searchStackView.centerYAnchor),
            searchTextField.trailingAnchor.constraint(equalTo: searchStackView.trailingAnchor, constant: -8),
            
            stackViewUnderLineView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor, constant: 2),
            stackViewUnderLineView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            stackViewUnderLineView.heightAnchor.constraint(equalToConstant: 1),
            
            searchHistoryCollectionView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor, constant: 8),
            searchHistoryCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            searchHistoryCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            searchHistoryCollectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            
        ])
    }
    
    private func configureDataSource() {
        cellRegistration = SearchHistoryCellRegistration { (cell, indexPath, item) in
            cell.item = item
        }
        
        dataSource = SearchHistoryDataSource(collectionView: searchHistoryCollectionView) { (collectionView, indexPath, identifier) -> UICollectionViewListCell in
            let cell = collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: identifier)
            cell.removeAction = {
                self.update(removedCell: cell)
            }
            
            return cell
        }
        
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([0])
        dataSource.apply(snapshot)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func update(removedCell: SearchHistoryCollectionViewCell) {
        var snapshot = self.dataSource.snapshot()
        var searchHistories = snapshot.itemIdentifiers(inSection: 0)
        
        // UserDefault 삭제
        guard let index = snapshot.indexOfItem(removedCell.item) else { return }
        searchHistories.remove(at: index)
        self.historyRepository.save(data: searchHistories)
        
        // dataSource 삭제
        snapshot.deleteItems([removedCell.item])
        self.dataSource.apply(snapshot)
    }
}

// MARK: - 검색기록 저장

// TODO: cell 클릭했을 때도 UserDefault에 저장하도록 로직 (이건 여기서 하는건 아님)
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let search = textField.text else { return true }
        let history = SearchHistory(title: search, created: Date())
        update(history)
        return true
    }
    
    private func update(_ history: SearchHistory) {
        var searchHistories = dataSource.snapshot().itemIdentifiers(inSection: 0)
        searchHistories.insert(history, at: 0)
        if searchHistories.count >= 10 {
            searchHistories.removeLast()
        }
        historyRepository.save(data: searchHistories)
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, SearchHistory>()
        snapshot.appendSections([0])
        snapshot.appendItems(searchHistories, toSection: 0)
        dataSource.apply(snapshot)
    }
}
