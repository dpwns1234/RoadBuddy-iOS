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
    
    typealias AddressRegistration = UICollectionView.CellRegistration<DetailAddressCollectionViewCell, SearchDataModel>
    // TODO: dataSource 하나로 합치기! (Section Hashable로 바꿈. switch로 구분해서 registration 적용)
    
    private var addressCellRegistration: AddressRegistration!
    
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
        searchCollectionView.delegate = self
        configureNavigationItem()
    }
    
    private func configureNavigationItem() {
        let searchController = UISearchController()
        searchController.searchBar.barStyle = .black
//        self.navigationItem.searchController = searchController
//        self.navigationItem.hidesSearchBarWhenScrolling = true
//        self.navigationItem.hidesBackButton = true
        self.navigationItem.hidesBackButton = true
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
        let searchHistories = historyRepository.fetch() ?? []
        var snapshot = searchDataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.history, .address])
        snapshot.appendItems(searchHistories, toSection: .history)
        searchDataSource.apply(snapshot)
    }
}

// MARK: - UITextFieldDelegate (엔터, 자동완성)

// TODO: 자동완성 -> 입력 다 지웠을 떄 검색기록 나오게 하기. / 입력할 떄 자동완성 api call 하기 / (검색기록 그리고 주소정보 클릭했을 떄 화면 전환 로직
extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let search = textField.text else { return true }
        let history = SearchDataModel(title: search, created: Date())
        record(history)
        return true
    }
        
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        loadSearchHistory()
        return true
    }
    
    // 자동완성
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /* string: 새로 들어온 글자 (지웠을 때는 empty)
        * currentText: 이전 글자
        * newText: 새로 변화되는 글자 (완성된 글자) - TODO: 한글로 제대로 입력되는지 확인
        */
        // 채팅창이 비었을 때 -> 검색기록 표시
        let currentText = (textField.text ?? "") as NSString
        let newText = currentText.replacingCharacters(in: range, with: string)
        if newText.isEmpty {
            loadSearchHistory()
            return true
        }
        // 하나라도 입력되었을 때 -> 자동완성 셀 표시
        loadAddress()
        
        return true
    }
    
    // test 로직 -> 여기서 자동완성 로직 아마?
    private func loadAddress() {
        var snapshot = searchDataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.history, .address])
        let model1 = SearchDataModel(title: "한성대학교1", address: "삼선교 어딘1", category: "대학교2", distance: 124)
        let model2 = SearchDataModel(title: "한성대학교2", address: "삼선교 어딘2", category: "대학교2", distance: 124)
        let model3 = SearchDataModel(title: "한성대학교4", address: "삼선교 어딘3", category: "대학교2", distance: 124)
        snapshot.appendItems([model1, model2, model3], toSection: .address)
        searchDataSource.apply(snapshot)
    }
}

// MARK: - 검색기록 저장, 삭제, 업데이트

extension SearchViewController {
    
    private func record(_ history: SearchDataModel) {
        var searchHistories = historyRepository.fetch() ?? []
        searchHistories.insert(history, at: 0)
        if searchHistories.count >= 10 {
            searchHistories.removeLast()
        }
        historyRepository.save(data: searchHistories)
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
    
    private func updateHistory(dataIndex: Int) {
        guard var searchHistories = historyRepository.fetch() else { return }
        let selectedItem = searchHistories.remove(at: dataIndex)
        searchHistories.insert(selectedItem, at: 0)
        historyRepository.save(data: searchHistories)
        
        // textField 채워넣기
        searchTextField.text = selectedItem.title
    }
}

// MARK: - UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: 이거 할 차례
        // 검색기록을 클릭했을 경우와 주소 셀을 클릭했을 경우.
        // 검색기록을 클릭할 경우 -> textField에 그 텍스트 값 넣어주고 주소정보 cell list를 띄워주기까지 (이게 맞는 듯 한데)
        guard let section = Section(rawValue: indexPath.section) else { return }
        let snapshot = searchDataSource.snapshot()
        var collectionViewItems = snapshot.itemIdentifiers
        switch section {
        case .history:
            updateHistory(dataIndex: indexPath.row)
            loadAddress()
        case .address:
            // 지도앱 띄어주기 = 이전 화면으로 이동? -> 그러면 x누르거나 네비게이션으로 다시 뒤로 타면 어떻게 돼?
            let selectedItem = collectionViewItems[indexPath.row]
            displayBottomSheet()
        }
    }
    
    private func displayBottomSheet() {
        let bottomVC = BottomSheetViewController()
        if let sheet = bottomVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(bottomVC, animated: true)
        dismiss(animated: false)
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
