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
        textField.changePlaceholderText(content: "장소, 버스, 지하철, 주소 검색", color: Hansung.grey.color)
        textField.textColor = .black
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
        collectionView.backgroundColor = .white
        
        return collectionView
    }()
    
    private let historyRepository = UserDefaultRepository<[SearchDataModel]>()
    private let addressDataManager = AddressDataManager()
    
    // MARK: - RouteDataSource
    
    typealias SearchDataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias HistoryCellRegistration = UICollectionView.CellRegistration<SearchHistoryCollectionViewCell, SearchDataModel>
    typealias AddressRegistration = UICollectionView.CellRegistration<DetailAddressCollectionViewCell, Address>
    
    private var historyCellRegistration: HistoryCellRegistration!
    private var addressCellRegistration: AddressRegistration!
    private var searchDataSource: SearchDataSource!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(searchStackView)
        self.view.addSubview(searchCollectionView)
        self.view.addSubview(stackViewUnderLineView)
        configureSearchDataSource()
        setConstraints()
        
        searchTextField.delegate = self
        searchCollectionView.delegate = self
        addressDataManager.delegate = self
        backButton.addTarget(self, action: #selector(touchedBackButton), for: .touchUpInside)
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
            guard let section = Section(rawValue: indexPath.section) else {
                return UICollectionViewListCell()
            }
            switch section {
            case .history:
                let identifier = identifier as? SearchDataModel
                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: self.historyCellRegistration,
                    for: indexPath,
                    item: identifier)
                cell.removeAction = { self.removed(cell) }
                return cell
            case .address:
                let identifier = identifier as? Address
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
        let searchHistories = historyRepository.fetch(type: "search") ?? []
        var snapshot = searchDataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.history, .address])
        snapshot.appendItems(searchHistories, toSection: .history)
        searchDataSource.apply(snapshot)
    }
}

// MARK: - UITextFieldDelegate (엔터, 자동완성)

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let search = textField.text else { return true }
        let history = SearchDataModel(title: search, created: Date())
        record(history)
        addressDataManager.fetchData(input: search)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        loadSearchHistory()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 채팅창이 비었을 때 -> 검색기록 표시
        let currentText = (textField.text ?? "") as NSString
        var newText = currentText.replacingCharacters(in: range, with: string)
        if newText.isEmpty {
            loadSearchHistory()
            return true
        }
        newText = combineHangul(jamo: newText)
        // 하나라도 입력되었을 때 -> 자동완성 셀 표시
        addressDataManager.fetchData(input: newText)
        
        return true
    }
    
    
    private func combineHangul(jamo: String) -> String {
        let initialConsonants: [Character] = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
        let vowels: [Character] = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]
        let finalConsonants: [Character] = [" ", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
        
        var result = ""
        var tempJamo = Array(jamo)
        
        while tempJamo.count >= 2 {
            if let initialIndex = initialConsonants.firstIndex(of: tempJamo[0]),
               let vowelIndex = vowels.firstIndex(of: tempJamo[1]) {
                let finalIndex = tempJamo.count > 2 ? finalConsonants.firstIndex(of: tempJamo[2]) ?? 0 : 0
                let unicode = 0xAC00 + (initialIndex * 21 * 28) + (vowelIndex * 28) + finalIndex
                result.append(Character(UnicodeScalar(unicode)!))
                tempJamo.removeFirst(2 + (finalIndex != 0 ? 1 : 0))
            } else {
                result.append(tempJamo.removeFirst())
            }
        }
        
        result.append(contentsOf: tempJamo)
        
        return result
    }
    
}

// MARK: - 검색기록 저장, 삭제, 업데이트

extension SearchViewController {
    
    private func record(_ history: SearchDataModel) {
        var searchHistories = historyRepository.fetch(type: "search") ?? []
        searchHistories.insert(history, at: 0)
        if searchHistories.count >= 10 {
            searchHistories.removeLast()
        }
        historyRepository.save(data: searchHistories)
    }
    
    private func removed(_ cell: SearchHistoryCollectionViewCell) {
        var snapshot = self.searchDataSource.snapshot()
        var searchHistories = snapshot.itemIdentifiers(inSection: Section.history) as! [SearchDataModel]
        
        // UserDefault 삭제
        guard let index = snapshot.indexOfItem(cell.item) else { return }
        searchHistories.remove(at: index)
        self.historyRepository.save(data: searchHistories)
        
        // dataSource 삭제
        snapshot.deleteItems([cell.item])
        self.searchDataSource.apply(snapshot)
    }
    
    private func updateHistory(dataIndex: Int) {
        guard var searchHistories = historyRepository.fetch(type: "search") else { return }
        let selectedItem = searchHistories.remove(at: dataIndex)
        searchHistories.insert(selectedItem, at: 0)
        historyRepository.save(data: searchHistories)
    }
}

// MARK: - UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        let snapshot = searchDataSource.snapshot()
        let collectionViewItems = snapshot.itemIdentifiers
        
        switch section {
        case .history:
            let selectedItem = collectionViewItems[indexPath.row] as! SearchDataModel
            updateHistory(dataIndex: indexPath.row)
            addressDataManager.fetchData(input: selectedItem.title)
            // textField 채워넣기
            searchTextField.text = selectedItem.title
        case .address:
            let selectedItem = collectionViewItems[indexPath.row] as! Address
            let resultVC = SearchResultViewController(addressData: selectedItem)
            record(selectedItem.toSearchDataModel)
            navigationController?.pushViewController(resultVC, animated: true)
        }
    }
}

// MARK: - AddressDataManagerDelegate

extension SearchViewController: AddressDataManagerDelegate {
    
    func addressData(_ dataManager: AddressDataManager, didLoad addresses: [Address]) {
        var snapshot = searchDataSource.snapshot()
        var refinedAddress = addresses
        refinement(addresses: &refinedAddress)
        snapshot.deleteAllItems()
        snapshot.appendSections([.history, .address])
        snapshot.appendItems(refinedAddress, toSection: .address)
        searchDataSource.apply(snapshot)
    }
    
    private func refinement(addresses: inout [Address]) {
        for index in addresses.indices {
            let refinedTitle = addresses[index].title.removingHTMLEntities()!
            addresses[index].title = refinedTitle
        }
    }
}

// MARK: - Layout (Constraints etc..)

extension SearchViewController {
    
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = .white
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
            stackViewUnderLineView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            stackViewUnderLineView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            stackViewUnderLineView.heightAnchor.constraint(equalToConstant: 1),
            
            searchCollectionView.topAnchor.constraint(equalTo: stackViewUnderLineView.bottomAnchor),
            searchCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            searchCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            searchCollectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            
        ])
    }
}
