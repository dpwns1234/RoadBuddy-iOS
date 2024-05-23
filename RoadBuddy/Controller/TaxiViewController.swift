//
//  TaxiViewController.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/22/24.
//

import UIKit

final class TaxiViewController: UIViewController {
    private let taxiImageView: UIImageView = {
        let imageView = UIImageView(image: .callTaxi)
        
        return imageView
    }()
    
    private lazy var totalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.layer.borderColor = UIColor.green.cgColor
        stackView.layer.cornerRadius = 8
        stackView.layer.borderWidth = 1
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30)
        
        stackView.addArrangedSubview(taxiImageView)
        stackView.addArrangedSubview(mainStackView)
        stackView.addArrangedSubview(callButton)
        
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 32
        
        return stackView
    }()
    
    private lazy var subStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 32
        stackView.alignment = .center
        
        
        return stackView
    }()
    
    private lazy var callButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("바로콜 신청하기", for: .normal)
        button.tintColor = .white
        button.backgroundColor = Hansung.darkBlue.color
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.addTarget(self, action: #selector(callTaxiButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private let addressRepository = UserDefaultRepository<Address>()
    private let driveDataService = DriveDataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(taxiImageView)
        self.view.addSubview(subStackView)
        self.view.addSubview(totalStackView)
        driveDataService.delegate = self
        
        setConstraints()
        apiCall()
    }
    
    func apiCall() {
        guard
            let departure = addressRepository.fetch(type: "departure")?.geocoding.addresses[0],
            let arrival = addressRepository.fetch(type: "arrival")?.geocoding.addresses[0]
        else {
            print("departure or arrival is nil!")
            return
        }
        
        do {
            try driveDataService.convertData(type: .drive(departureLocation: departure.locatoin, arrivalLocation: arrival.locatoin))
        } catch {
            print(error)
        }
    }
}

// MARK: - DriveDataServiceDelegate
extension TaxiViewController: DriveDataServiceDelegate {
    
    func driveDataService(_ service: DriveDataService, didDownlad drive: Drive) {
        DispatchQueue.main.async {
            self.bind(drive.data.features[0].properties)
        }
    }
    private func bind(_ drive: Properties) {
        let (totalPeople, nearbyPeople, watingTime) = generateRandomValues(randomNumber: drive.totalTime!/30)
        let main1 = createVerticalStackView(title: "전체 대기", value: totalPeople, unit: "명")
        let main2 = createVerticalStackView(title: "주변 대기", value: nearbyPeople, unit: "명")
        let main3 = createVerticalStackView(title: "평균배차대기", value: watingTime, unit: "분")
        mainStackView.addArrangedSubview(main1)
        mainStackView.addArrangedSubview(main2)
        mainStackView.addArrangedSubview(main3)
        
        let min = String(drive.totalTime! / 60)
        let fare = formatCurrency(amount: drive.taxiFare!)
        let sub1 = createVerticalStackView(title: "이동 시간", value: min, unit: "분")
        let sub2 = createVerticalStackView(title: "일반택시요금", value: fare, unit: "원")
        subStackView.addArrangedSubview(sub1)
        subStackView.addArrangedSubview(sub2)
    }
    
    private func formatCurrency(amount: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedAmount = numberFormatter.string(from: NSNumber(value: amount)) ?? ""
        return formattedAmount
    }
    
    private func generateRandomValues(randomNumber: Int) -> (totalPeopleWaiting: String, nearbyPeopleWaiting: String, taxiDispatchWaitingTime: String) {
        let totalPeopleWaiting = randomNumber
        let nearbyPeopleWaiting = Int.random(in: 0...totalPeopleWaiting)
        let taxiDispatchWaitingTime = nearbyPeopleWaiting/2

        return (String(totalPeopleWaiting), String(nearbyPeopleWaiting), String(taxiDispatchWaitingTime))
    }
}

// MARK: - Alert
extension TaxiViewController {
    
    @objc
    func callTaxiButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "장애인 콜택시", message: "호출하시겠습니까?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "아니오", style: .destructive)
        let yesAction = UIAlertAction(title: "호출", style: .default) { (_) in
            self.showSecondAlert()
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
    
        present(alert, animated: true, completion: nil)
    }
    
    func showSecondAlert() {
        let secondAlert = UIAlertController(title: "호출 완료", message: "차량이 출발지 주변에 도착하면 연락 드립니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        secondAlert.addAction(okAction)
        present(secondAlert, animated: true, completion: nil)
    }
}

// MARK: - Configure Layout

extension TaxiViewController {
    
    private func createVerticalStackView(title: String, value: String, unit: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        
        let titleFont = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize)
        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .body)
        
        let valueLabel = UILabel()
        let attributedString = NSMutableAttributedString(string: value+unit)
        attributedString.addAttribute(.font, value: titleFont, range: NSRange(0..<value.count))
        attributedString.addAttribute(.font, value: bodyFont, range: NSRange(value.count..<value.count+unit.count))
        valueLabel.attributedText = attributedString
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
        
        return stackView
    }
    
    private func setConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            subStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 48),
            subStackView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
            taxiImageView.widthAnchor.constraint(equalToConstant: 180),
            taxiImageView.heightAnchor.constraint(equalToConstant: 180),
            
            totalStackView.topAnchor.constraint(equalTo: subStackView.bottomAnchor, constant: 48),
            totalStackView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
        ])
    }
}
