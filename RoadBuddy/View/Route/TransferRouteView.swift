//
//  TransferRouteView.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/20/24.
//

import UIKit

final class TransferRouteView: UIView {
    var transferPath: Transfer?
    
    private var verticalStepLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let font = UIFont.preferredFont(forTextStyle: .title3)
        label.font = .boldSystemFont(ofSize: font.pointSize)
        label.text = "환승 이동"
        label.textColor = .black
        
        return label
    }()
    
    private let transferStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        
        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private var lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        
        return view
    }()
    
    init(transferPath: Transfer) {
        super.init(frame: .zero)
        
        backgroundColor = .white
        self.addSubview(verticalStepLineView)
        self.addSubview(titleLabel)
        self.addSubview(transferStackView)
        self.addSubview(imageView)
        self.addSubview(lineView)
        
        bind(data: transferPath)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind(data transferPath: Transfer) {
        for path in transferPath.mvContDtl {
            let pathLabel = UILabel()
            pathLabel.text = path
            pathLabel.textColor = .black
            transferStackView.addArrangedSubview(pathLabel)
        }
        
        loadImage(from: transferPath.imgPath)
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let image = UIImage(data: data)
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = image
            }
        }.resume()
    }
    
    private func setConstraints() {
        let safeArea = self.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            verticalStepLineView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            verticalStepLineView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            verticalStepLineView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            verticalStepLineView.widthAnchor.constraint(equalToConstant: 8),
            
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: verticalStepLineView.trailingAnchor, constant: 16),
            
            transferStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            transferStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            imageView.topAnchor.constraint(equalTo: transferStackView.bottomAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            lineView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            lineView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            
        ])
    }
}
