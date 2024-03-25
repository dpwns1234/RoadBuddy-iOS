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
    
    private lazy var searchCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    // MARK: - SearchHistory
    
    typealias SearchHistoryDataSource = UICollectionViewDiffableDataSource<Int, SearchHistory> // TODO: Section으로 구분?
    typealias SearchHistoryCellRegistration = UICollectionView.CellRegistration<SearchHistoryCollectionViewCell, SearchHistory>
    
    private let historyRepository = UserDefaultRepository<[SearchHistory]>()
    private var historyDataSource: SearchHistoryDataSource!
    private var searchCellRegistration: SearchHistoryCellRegistration!
    
    // MARK: - DetailAddress
    
    typealias DetailAddressDataSource = UICollectionViewDiffableDataSource<Int, DetailAddress>
    typealias DetailAddressRegistration = UICollectionView.CellRegistration<DetailAddressCollectionViewCell, DetailAddress>
    
    private var addressDataSource: DetailAddressDataSource!
    private var addressCellRegistration: DetailAddressRegistration!
    
    // TODO: 지금 나갔다 들어오면 제대로 저장을 못하는 상황임. 어쩔땐 저장되고 어쩔 땐 변경내역이 반영이 안됨.
    
    // TODO: willAppear 경우: 네비게이션으로 이동 후 다시 백버튼 눌렀을 때(검색기록 누르면 텍스트필드에 그게 들어가게 하고, 디테일주소로 이동) = addrssDataSource를 받아야 하는게 맞음.
    // TODO: 텍스트필드 입력시 셀이 변하는 거니까 뷰컨이 두 개 되면 안 됨. 정안되면 한 화면에 컬렉션뷰가 두 개가 되어야 함.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        var addressSnapshot = addressDataSource.snapshot()
        var snapshot = historyDataSource.snapshot()
        let searchHistories = historyRepository.fetch() ?? [SearchHistory]()
        snapshot.appendItems([], toSection: 1)
//        addressSnapshot.deleteAllItems()
//        addressDataSource.apply(addressSnapshot)
//        addressDataSource.apply(snapshot)
        historyDataSource.apply(snapshot)
    }
    // 섹션으론 구분이 되는가?
    // 데이터 모델을 하나로 합치는건? -> cellRegistration이 다르지. contentView랑.
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(searchStackView)
        self.view.addSubview(searchCollectionView)
        self.view.addSubview(stackViewUnderLineView)
        configureHistoryDataSource()
        configureAddressDataSource()
        setConstraints()
        
        searchTextField.delegate = self
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
    
    private func configureHistoryDataSource() {
        searchCellRegistration = SearchHistoryCellRegistration { (cell, indexPath, item) in
            cell.item = item
        }
        
        historyDataSource = SearchHistoryDataSource(collectionView: searchCollectionView) { (collectionView, indexPath, identifier) -> UICollectionViewListCell in
            let cell = collectionView.dequeueConfiguredReusableCell(using: self.searchCellRegistration, for: indexPath, item: identifier)
            cell.removeAction = {
                self.update(removedCell: cell)
            }
            
            return cell
        }

        var snapshot = historyDataSource.snapshot()
        snapshot.appendSections([1])
        historyDataSource.apply(snapshot)
    }
    
    private func configureAddressDataSource() {
        addressCellRegistration = DetailAddressRegistration { (cell, indexPath, item) in
            cell.item = item
        }
        
        addressDataSource = DetailAddressDataSource(collectionView: searchCollectionView, cellProvider: { collectionView, indexPath, identifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: self.addressCellRegistration, for: indexPath, item: identifier)

            return cell
        })
        
        var snapshot = addressDataSource.snapshot()
        snapshot.appendSections([0])
        // MARK: Test
        let detailAddress1 = DetailAddress(title: "한성대학교", address: "삼선교 어딘가", category: "대학교", distance: 12)
        let detailAddress2 = DetailAddress(title: "한성대학교1", address: "삼선교 어딘가1", category: "대학교1", distance: 123)
        let detailAddress3 = DetailAddress(title: "한성대학교2", address: "삼선교 어딘가2", category: "대학교2", distance: 124)
        snapshot.appendItems([detailAddress1, detailAddress2, detailAddress3])
        addressDataSource.apply(snapshot)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func update(removedCell: SearchHistoryCollectionViewCell) {
        var snapshot = self.historyDataSource.snapshot()
        var searchHistories = snapshot.itemIdentifiers(inSection: 0)
        
        // UserDefault 삭제
        guard let index = snapshot.indexOfItem(removedCell.item) else { return }
        searchHistories.remove(at: index)
        self.historyRepository.save(data: searchHistories)
        
        // dataSource 삭제
        snapshot.deleteItems([removedCell.item])
        self.historyDataSource.apply(snapshot)
    }
}

// MARK: - 검색기록 저장

// TODO: cell 클릭했을 때도 UserDefault에 저장하도록 로직 (이건 여기서 하는건 아님)
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let search = textField.text else { return true }
        let history = SearchHistory(title: search, created: Date())
        save(history)
        return true
    }
    
    private func save(_ history: SearchHistory) {
        var searchHistories = historyDataSource.snapshot().itemIdentifiers(inSection: 0)
        searchHistories.insert(history, at: 0)
        if searchHistories.count >= 10 {
            searchHistories.removeLast()
        }
        historyRepository.save(data: searchHistories)
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, SearchHistory>()
        snapshot.appendSections([1])
        snapshot.appendItems(searchHistories, toSection: 1)
        historyDataSource.apply(snapshot)
    }
}
