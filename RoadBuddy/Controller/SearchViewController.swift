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
        // TODO: 원소를 하나씩 추가해야하나? 아니면 array로 새로 갈아 끼우는 건가?
        let searchHistories = decode()
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
            collectionView.allowsSelection = false
            return collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: identifier)
        }
        
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([0])
        dataSource.apply(snapshot)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

// MARK: - 검색기록 저장

// TODO: 10개만 저장하고 누적되면 알아서 마지막거 지우기(stack) + cell 클릭했을 때도 UserDefault에 저장하도록 로직 (이건 여기서 하는건 아님)
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let search = textField.text else { return true }
        let searchObj = SearchHistory(title: search, created: Date())
        var searchHistories = decode()
        searchHistories.insert(searchObj, at: 0)
        // 10개 이상
        if searchHistories.count >= 10 {
            searchHistories.removeLast()
        }
        encodeAndSave(searchHistories)
        
        // TODO: 나중에 section 나눴을 때도 정상적으로 될지는 모르겠다.. (근데 아마 될 듯!)
        var snapshot = NSDiffableDataSourceSnapshot<Int, SearchHistory>()
        snapshot.appendSections([0])
        snapshot.appendItems(searchHistories, toSection: 0)
        dataSource.apply(snapshot)
        
        return true
    }
    
    // TODO: 나중에 클래스화 하던지 ㅇㅇ
    private func decode() -> [SearchHistory] {
        let decoder = JSONDecoder()
        if let savedData = UserDefaults.standard.object(forKey: "searchHistories") as? Data {
            // TODO: force unwarpping
            let searchHistories = try! decoder.decode([SearchHistory].self, from: savedData)
            return searchHistories
        }
        return [SearchHistory]()
    }
    
    private func encodeAndSave(_ searchHistories: [SearchHistory]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(searchHistories) {
            UserDefaults.standard.setValue(encoded, forKey: "searchHistories")
            UserDefaults.standard.synchronize()
        }
    }
}
// 해결해야겠단 생각은 버려!
