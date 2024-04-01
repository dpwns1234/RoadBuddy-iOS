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
//        collectionView.allowsSelection = false // TODO: 근데 이거 헀다고 셀 클릭했을 떄 화면전환 안되는거 아니겠지??
        
        return collectionView
    }()
    
    // MARK: - SearchDataSource
    
    typealias SearchDataSource = UICollectionViewDiffableDataSource<Section, SearchDataModel>
    typealias HistoryCellRegistration = UICollectionView.CellRegistration<SearchHistoryCollectionViewCell, SearchDataModel>
    
    private var searchDataSource: SearchDataSource!
    private var historyCellRegistration: HistoryCellRegistration!
    
    private let historyRepository = UserDefaultRepository<[SearchDataModel]>()
    
    // MARK: - LifeCycle
    
    // TODO: willAppear 경우: 네비게이션으로 이동 후 다시 백버튼 눌렀을 때(검색기록 누르면 텍스트필드에 그게 들어가게 하고, 디테일주소로 이동) = addrssDataSource를 받아야 하는게 맞음.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(searchStackView)
        self.view.addSubview(searchCollectionView)
        self.view.addSubview(stackViewUnderLineView)
        configureSearchDataSource()
        setConstraints()
        backButton.addTarget(self, action: #selector(touchedBackButton), for: .touchUpInside)
        searchTextField.delegate = self 
    }
    
    @objc
    private func touchedBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Configure DataSource

extension SearchViewController {
    
    private func configureSearchDataSource() {
        configureRegistration()
        
        searchDataSource = SearchDataSource(collectionView: searchCollectionView) { (collectionView, indexPath, identifier) -> UICollectionViewListCell in
            let cell = collectionView.dequeueConfiguredReusableCell(
                using: self.historyCellRegistration,
                for: indexPath,
                item: identifier)
            
            cell.removeAction = { self.removed(cell) }
            return cell
        }
        loadSearchHistory()
    }
    
    private func configureRegistration() {
        historyCellRegistration = HistoryCellRegistration { (cell, indexPath, item) in
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

// MARK: - UITextFieldDelegate (엔터, 자동완성)

// TODO: cell 클릭했을 때도 UserDefault에 저장하도록 로직 (이건 여기서 하는건 아님)
// TODO: 자동완성 -> 입력 다 지웠을 떄 검색기록 나오게 하기. / 입력할 떄 자동완성 api call 하기 / (검색기록 그리고 주소정보 클릭했을 떄 화면 전환 로직
extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let search = textField.text else { return true }
        let history = SearchDataModel(title: search, created: Date())
        record(history)
        return true
    }
    
    // 여기서 화면전환 생각
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if ((textField.text?.isEmpty) != nil) {
//            print("empty")
//            return true
//        }
        var snapshot = searchDataSource.snapshot()
        snapshot.deleteSections([.history])
        let model3 = SearchDataModel(title: "한성대학교4", address: "삼선교 어딘2", category: "대학교2", distance: 124)
        snapshot.appendItems([model3], toSection: Section.address)
        searchDataSource.apply(snapshot)
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        var snapshot = searchDataSource.snapshot()
        snapshot.deleteSections([.address])
        snapshot.appendSections([.history])
        let histories = historyRepository.fetch()
        snapshot.appendItems(histories ?? [])
        searchDataSource.apply(snapshot)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("didEnd")
        if ((textField.text?.isEmpty) != nil) {
            print("empty")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // string: 새로 들어온 글자
        // currentText: 이전 글자
        // newText: 새로 변화되는 글자
        let currentText = (textField.text ?? "") as NSString
        let newText = currentText.replacingCharacters(in: range, with: string)
        
        // Filter the search results based on the new text
        //            filterSearchResults(with: newText)
        return true
    }
}

// MARK: - 검색기록 저장, 삭제

extension SearchViewController {
    
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
            
            searchCollectionView.topAnchor.constraint(equalTo: stackViewUnderLineView.bottomAnchor),
            searchCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            searchCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            searchCollectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            
        ])
    }
}
