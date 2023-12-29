//
//  ViewModel.swift
//  TryWeatherApp
//
//  Created by Александр on 27.12.2023.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

public final class ViewModel {
    
    // MARK: - Properties
    
    private let networkManager = NetworkManager()
    private let disposeBag = DisposeBag()
    
    private let forecastDaysSubject = BehaviorSubject<[ForecastDay]>(value: [])
    public var forecastDaysObservable: Observable<[ForecastDay]> {
        return forecastDaysSubject.asObservable()
    }
    private let weatherSubject = BehaviorSubject<Weather?>(value: nil)
    public var weatherObservable: Observable<Weather?> {
        return weatherSubject.asObservable()
    }
    
    // Define Observables for UI elements
    public let cityObservable: BehaviorSubject<String>
    public let temperatureObservable: BehaviorSubject<String>
    public let descriptionObservable: BehaviorSubject<String>
    public let iconLabelObservable: BehaviorSubject<String>
    public let windObservable: BehaviorSubject<String>
    
    // MARK: - Init
    
    init() {
        // Initialize Observables
        cityObservable = BehaviorSubject<String>(value: "")
        temperatureObservable = BehaviorSubject<String>(value: "")
        descriptionObservable = BehaviorSubject<String>(value: "")
        iconLabelObservable = BehaviorSubject<String>(value: "")
        windObservable = BehaviorSubject<String>(value: "")
        
        subOnChange()
    }
    
    // MARK: - Update data
    
    func subOnChange() {
        // Subscribe to the Observable for weather data
        networkManager.weatherObservable
            .subscribe(onNext: { [weak self] weather in
                    guard let self = self, let weather = weather else { return }

                // Update UI elements with weather data
                self.cityObservable.onNext(weather.city)
                self.descriptionObservable.onNext(weather.today.description)

                let temperatureExplanation = " \(weather.today.temperature)°C"
                self.temperatureObservable.onNext(temperatureExplanation)

                let icon = ViewModel.IconChange(rawValue: weather.today.iconName)?.emoji ?? "❓"
                self.iconLabelObservable.onNext(icon)

                let windExplanation = "Скорость ветра: \(weather.today.windSpeed) m/s"
                self.windObservable.onNext(windExplanation)

                // Update today and forecastDays using PublishSubject
                self.forecastDaysSubject.onNext(weather.forecastDays)
            })
            .disposed(by: disposeBag)

        // Start loading weather data
        networkManager.loadWeatherData()
    }
    
    // MARK: - Search update data
    
    public func loadWeatherDataForSearch(forCity cityName: String) {
        networkManager.loadWeatherDataForSearch(forCity: cityName)
    }
    
}

// MARK: - Extension

extension ViewModel {
    static func convertTimestampToDate(_ timestamp: String) -> String {
        guard let timestampDouble = Double(timestamp) else {
            return "Invalid Timestamp"
        }

        let date = Date(timeIntervalSince1970: timestampDouble)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd" // Укажите желаемый формат даты
        return dateFormatter.string(from: date)
    }
}

// MARK: - Private extension

private extension ViewModel {
    enum IconChange: String {
        case drizzle = "Drizzle"
        case thunderstorm = "Thunderstorm"
        case rain = "Rain"
        case snow = "Snow"
        case clear = "Clear"
        case clouds = "Clouds"
        
        var emoji: String {
            switch self {
            case .drizzle: return "🌧️"
            case .thunderstorm: return "⛈️"
            case .rain: return "🌧️"
            case .snow: return "❄️"
            case .clear: return "☀️"
            case .clouds: return "☁️"
            }
        }
    }
}
