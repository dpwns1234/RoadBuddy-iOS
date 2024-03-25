//
//  SearchViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/17/24.
//

import UIKit

final class SearchViewController: UIViewController {
    
    // MARK: - UI Properties
    
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
    
    private lazy var searchCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    // MARK: - SearchDataSource
    
    typealias SearchDataSource = UICollectionViewDiffableDataSource<Section, SearchDataModel>
    typealias HistoryCellRegistration = UICollectionView.CellRegistration<SearchHistoryCollectionViewCell, SearchDataModel>
    typealias AddressRegistration = UICollectionView.CellRegistration<DetailAddressCollectionViewCell, SearchDataModel>
    
    private var searchDataSource: SearchDataSource!
    private var historyCellRegistration: HistoryCellRegistration!
    private var addressCellRegistration: AddressRegistration!
    
    private let historyRepository = UserDefaultRepository<[SearchDataModel]>()
    
    // MARK: - LifeCycle
    
    // TODO: 지금 나갔다 들어오면 제대로 저장을 못하는 상황임. 어쩔땐 저장되고 어쩔 땐 변경내역이 반영이 안됨.
    
    // TODO: willAppear 경우: 네비게이션으로 이동 후 다시 백버튼 눌렀을 때(검색기록 누르면 텍스트필드에 그게 들어가게 하고, 디테일주소로 이동) = addrssDataSource를 받아야 하는게 맞음.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let detailAddress1 = SearchDataModel(title: "한성대학교", address: "삼선교 어딘가", category: "대학교", distance: 12)
        let detailAddress2 = SearchDataModel(title: "한성대학교1", address: "삼선교 어딘가1", category: "대학교1", distance: 123)
        let detailAddress3 = SearchDataModel(title: "한성대학교2", address: "삼선교 어딘가2", category: "대학교2", distance: 124)
        
        var snapshot = searchDataSource.snapshot()
        snapshot.appendSections([Section.address])
        snapshot.appendItems([detailAddress1, detailAddress2, detailAddress3], toSection: Section.address)
        searchDataSource.apply(snapshot)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(searchStackView)
        self.view.addSubview(searchCollectionView)
        self.view.addSubview(stackViewUnderLineView)
        configureSearchDataSource()
        setConstraints()
        
        searchTextField.delegate = self
    }
}

// MARK: - Configure DataSource

extension SearchViewController {
    
    private func configureSearchDataSource() {
        configureRegistration()
        
        searchDataSource = SearchDataSource(collectionView: searchCollectionView) { (collectionView, indexPath, identifier) -> UICollectionViewListCell in
            guard let section = Section(rawValue: indexPath.section) else { return UICollectionViewListCell() }
            switch section {
            case .history:
                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: self.historyCellRegistration,
                    for: indexPath,
                    item: identifier)
                cell.removeAction = { self.removed(cell) }
                return cell
            case .address:
                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: self.addressCellRegistration,
                    for: indexPath,
                    item: identifier)
                return cell
            }
        }
        
        loadSearchHistory()
    }
    
    private func configureRegistration() {
        historyCellRegistration = HistoryCellRegistration { (cell, indexPath, item) in
            cell.item = item
        }
        addressCellRegistration = AddressRegistration { (cell, indexPath, item) in
            cell.item = item
        }
    }
    
    private func loadSearchHistory() {
        var snapshot = searchDataSource.snapshot()
        snapshot.appendSections([Section.history])
        let searchHistories = historyRepository.fetch() ?? []
        snapshot.appendItems(searchHistories, toSection: Section.history)
        searchDataSource.apply(snapshot)
    }
}

// MARK: - 검색기록 저장, 삭제

// TODO: cell 클릭했을 때도 UserDefault에 저장하도록 로직 (이건 여기서 하는건 아님)
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let search = textField.text else { return true }
        let history = SearchDataModel(title: search, created: Date())
        record(history)
        return true
    }
    
    private func record(_ history: SearchDataModel) {
        var searchHistories = searchDataSource.snapshot().itemIdentifiers(inSection: Section.history)
        searchHistories.insert(history, at: 0)
        if searchHistories.count >= 10 {
            searchHistories.removeLast()
        }
        historyRepository.save(data: searchHistories)
        
        // TODO: 나중에는 dataSource에 반영하지 않고 UserDefault에만 저장하면 됨.
        var snapshot = searchDataSource.snapshot()
        snapshot.appendItems(searchHistories, toSection: Section.history)
        searchDataSource.apply(snapshot)
    }
    
    private func removed(_ cell: SearchHistoryCollectionViewCell) {
        var snapshot = self.searchDataSource.snapshot()
        var searchHistories = snapshot.itemIdentifiers(inSection: Section.history)
        
        // UserDefault 삭제
        guard let index = snapshot.indexOfItem(cell.item) else { return }
        searchHistories.remove(at: index)
        self.historyRepository.save(data: searchHistories)
        
        // dataSource 삭제
        snapshot.deleteItems([cell.item])
        self.searchDataSource.apply(snapshot)
    }
}

// MARK: - Layout (Constraints etc..)

extension SearchViewController {
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
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
            
            searchCollectionView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor, constant: 8),
            searchCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            searchCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            searchCollectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            
        ])
    }
}
