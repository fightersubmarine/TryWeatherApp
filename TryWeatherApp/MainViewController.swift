//
//  ViewController.swift
//  TryWeatherApp
//
//  Created by Александр on 26.12.2023.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MainViewController: UIViewController {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let viewModel = ViewModel()
    
    // MARK: - Create Ui elements
    
    lazy var cityTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search City"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    lazy var fetchWeatherButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go", for: .normal)
        button.backgroundColor = .systemPink.withAlphaComponent(Constants.alfa)
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.cornerRadius
        return button
    }()
    
    
    lazy var cityNameLabel: UILabel =  {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.backgroundColor = .systemPink.withAlphaComponent(Constants.alfa)
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: Constants.fontSize)
        label.layer.cornerRadius = Constants.cornerRadius
        label.clipsToBounds = true
        return label
    }()
    
    lazy var temperatureLabel: UILabel =  {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.backgroundColor = .gray.withAlphaComponent(Constants.alfa)
        label.font = UIFont.systemFont(ofSize: Constants.fontSize)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    lazy var discriotionLabel: UILabel =  {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.backgroundColor = .gray.withAlphaComponent(Constants.alfa)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    lazy var windLabel: UILabel =  {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.backgroundColor = .gray.withAlphaComponent(Constants.alfa)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    lazy var iconLabel: UILabel =  {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.backgroundColor = .gray.withAlphaComponent(Constants.alfa)
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: Constants.fontSize)
        return label
    }()
    
    lazy var forecastTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "forecastCell")
        tableView.layer.cornerRadius = Constants.cornerRadius
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    // MARK: - View hierarchy
    
    func addSubviews() {
        view.addSubview(cityNameLabel)
        view.addSubview(temperatureLabel)
        view.addSubview(iconLabel)
        view.addSubview(discriotionLabel)
        view.addSubview(windLabel)
        view.addSubview(cityTextField)
        view.addSubview(fetchWeatherButton)
        view.addSubview(forecastTableView)
    }
    
    // MARK: - Update view func
    
    func setUpBackgroundForView() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.gray.cgColor, UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func updateViewOnButtonPress() {
        fetchWeatherButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let cityName = self?.cityTextField.text else { return }
                self?.viewModel.loadWeatherDataForSearch(forCity: cityName)
            })
            .disposed(by: disposeBag)
    }
        
    func updateView() {
        viewModel.cityObservable.bind(to: cityNameLabel.rx.text).disposed(by: disposeBag)
        viewModel.temperatureObservable.bind(to: temperatureLabel.rx.text).disposed(by: disposeBag)
        viewModel.descriptionObservable.bind(to: discriotionLabel.rx.text).disposed(by: disposeBag)
        viewModel.iconLabelObservable.bind(to: iconLabel.rx.text).disposed(by: disposeBag)
        viewModel.windObservable.bind(to: windLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.forecastDaysObservable
            .map { forecastDays in
                var uniqueDates = Set<String>()
                var filteredForecast: [ForecastDay] = []

                for day in forecastDays {
                    let dateString = ViewModel.convertTimestampToDate(day.date)
                    if !uniqueDates.contains(dateString) {
                        uniqueDates.insert(dateString)
                        filteredForecast.append(day)
                    }
                }

                return filteredForecast.map { (ViewModel.convertTimestampToDate($0.date), $0.temperature, $0.description) }
            }
            .bind(to: forecastTableView.rx.items(cellIdentifier: "forecastCell")) { _, element, cell in
                self.configureCell(cell, withElement: element)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Constraints
    
    func setupConstraints() {
        
        forecastTableView.snp.makeConstraints { (make) in
            make.top.equalTo(windLabel.snp.bottom).offset(Constants.offset)
            make.bottom.equalToSuperview().inset(Constants.height)
            make.right.equalToSuperview().inset(Constants.offset)
            make.left.equalToSuperview().offset(Constants.offset)
        }
        
        cityTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.offsetForSearch)
            make.left.equalToSuperview().inset(Constants.offsetForSearch)
            make.width.equalTo(Constants.width)
            make.height.equalTo(Constants.height)
        }
        fetchWeatherButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.offsetForSearch)
            make.left.equalTo(cityTextField.snp.right).offset(Constants.offsetForButton)
            make.width.equalTo(Constants.weidthForButton)
            make.height.equalTo(Constants.height)
        }
        cityNameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.mainOffset)
            make.centerX.equalToSuperview()
            make.width.equalTo(Constants.width)
            make.height.equalTo(Constants.height)
        }
        temperatureLabel.snp.makeConstraints { (make) in
            make.top.equalTo(cityNameLabel.snp.bottom).offset(Constants.offset)
            make.centerX.equalToSuperview()
            make.size.equalTo(cityNameLabel)
        }
        iconLabel.snp.makeConstraints { (make) in
            make.top.equalTo(temperatureLabel.snp.bottom).offset(Constants.offset)
            make.centerX.equalToSuperview()
            make.size.equalTo(cityNameLabel)
        }
        discriotionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconLabel.snp.bottom).offset(Constants.offset)
            make.centerX.equalToSuperview()
            make.size.equalTo(cityNameLabel)
        }
        windLabel.snp.makeConstraints { (make) in
            make.top.equalTo(discriotionLabel.snp.bottom).offset(Constants.offset)
            make.centerX.equalToSuperview()
            make.size.equalTo(cityNameLabel)
        }
    }
    
    // MARK: - UI life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBackgroundForView()
        updateViewOnButtonPress()
        updateView()
        addSubviews()
        setupConstraints()
    }
}

// MARK: - Private Extension

private extension MainViewController {
    func configureCell(_ cell: UITableViewCell, withElement element: (String, String, String)) {
        let dateString = element.0
        let temperatureString = "\(element.1)°C"
        let descriptionString = element.2
        
        cell.textLabel?.text = "\(dateString): \(temperatureString) - \(descriptionString)"
        
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = .systemPink.withAlphaComponent(Constants.alfa)
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
    }
}

private extension MainViewController {
    enum Constants {
        static let cornerRadius = 10.0
        static let fontSize = 32.0
        static let offsetForSearch = 56.0
        static let weidthForButton = 50.0
        static let offsetForButton = 8.0
        static let alfa = 0.5
        static let mainOffset = 250.0
        static let offset = 10.0
        static let width = 250.0
        static let height = 40.0
    }
}
