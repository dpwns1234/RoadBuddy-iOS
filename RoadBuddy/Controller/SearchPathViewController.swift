//
//  SearchPathViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 4/8/24.
//

import UIKit

enum Direct {
    case departure
    case arrival
}

final class SearchPathViewController: UIViewController {
    
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
        button.setImage(.backButton, for: .normal)
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
    
    private lazy var searchCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private let historyRepository = UserDefaultRepository<[SearchDataModel]>()
    
    // MARK: - SearchDataSource
    
    typealias SearchDataSource = UICollectionViewDiffableDataSource<Section, SearchDataModel>
    typealias HistoryCellRegistration = UICollectionView.CellRegistration<SearchHistoryCollectionViewCell, SearchDataModel>
    
    private var historyCellRegistration: HistoryCellRegistration!
    private var searchDataSource: SearchDataSource!
    
    init(placeText: String, direct: Direct) {
        switch direct {
        case .departure:
            departureTextField.text = placeText
        case .arrival:
            arrivalTextField.text = placeText
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(tradeButton)
        self.view.addSubview(textFieldStackView)
        self.view.addSubview(xButton)
        self.view.addSubview(searchCollectionView)
        self.view.addSubview(stackViewUnderLineView)
        configureSearchDataSource()
        setConstraints()
        searchCollectionView.delegate = self
        
//        tradeButton.addTarget(self, action: #selector(touchedBackButton), for: .touchUpInside)
        xButton.addTarget(self, action: #selector(touchedXButton), for: .touchUpInside)
    }
    
    @objc
    private func touchedXButton() {
        // 처음 화면으로 ..
        dismiss(animated: true)
    }
}

// MARK: - Configure DataSource

extension SearchPathViewController {
    
    private func configureSearchDataSource() {
        configureRegistration()
        
        searchDataSource = SearchDataSource(collectionView: searchCollectionView) { (collectionView, indexPath, identifier) -> UICollectionViewListCell in
            
            guard let section = Section(rawValue: indexPath.section) else {
                return UICollectionViewListCell()
            }
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
        let searchHistories = historyRepository.fetch() ?? []
        var snapshot = searchDataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.history, .address])
        snapshot.appendItems(searchHistories, toSection: .history)
        searchDataSource.apply(snapshot)
    }
}

// MARK: - 검색기록 저장, 삭제, 업데이트

extension SearchPathViewController {
    
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
    }
}

// MARK: - UICollectionViewDelegate

extension SearchPathViewController: UICollectionViewDelegate {
    
    // 검색기록 선택했을 때 빈 곳에 자동으로 채워주기?
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snapshot = searchDataSource.snapshot()
        let histories = snapshot.itemIdentifiers
        updateHistory(dataIndex: indexPath.row)
        // 1. 셀 title을 빈 textField에 채우기
        if departureTextField.text!.isEmpty {
            departureTextField.text = histories[indexPath.row].title
        } else {
            arrivalTextField.text = histories[indexPath.row].title
        }
        // 2. 다 채워졌을 경우 collectionView의 셀을 길찾기 cell로 변경
    }
}

// MARK: - Layout (Constraints etc..)

extension SearchPathViewController {
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
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
            
            searchCollectionView.topAnchor.constraint(equalTo: stackViewUnderLineView.bottomAnchor),
            searchCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            searchCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            searchCollectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            
        ])
    }
}
