//
//  NetworkManager.swift
//  TryWeatherApp
//
//  Created by Александр on 26.12.2023.
//

import CoreLocation
import Foundation
import RxSwift

public final class NetworkManager: NSObject {
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    private let API_KEY = "d8ba3ef066ffba63d75f2d1c7a49cb72"
    
    private let weatherSubject = BehaviorSubject<Weather?>(value: nil)
    private let disposeBag = DisposeBag()
    
    public var weatherObservable: Observable<Weather?> {
        return weatherSubject.asObservable()
    }
    
    // MARK: - Init
    
    public override init() {
        super.init()
        locationManager.delegate = self
    }
    
    
    // MARK: - Working with API
    
    // MARK: Getting data by city name
    
    public func loadWeatherDataForSearch(forCity cityName: String) {
        guard let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(cityName)&appid=\(API_KEY)&lang=ru&units=metric".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else {
                return
            }
            if let response = try? JSONDecoder().decode(ApiResponse.self, from: data) {
                let weather = Weather(response: response)
                self.weatherSubject.onNext(weather)
            } else {
                return
            }
        }.resume()
    }
    
    
    // MARK: Receiving location data
    
    public func loadWeatherData() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func makeDataRequest(forCoordinates coordinates: CLLocationCoordinate2D) {
        guard let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&appid=\(API_KEY)&lang=ru&units=metric".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else {
                return
            }
            if let response = try? JSONDecoder().decode(ApiResponse.self, from: data) {
                let weather = Weather(response: response)
                self.weatherSubject.onNext(weather)
            } else {
            }
        }.resume()
    }
    
}

// MARK: - Extension for location

extension NetworkManager: CLLocationManagerDelegate {
    public func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else { return }
        print("Updated location: \(location.coordinate)")
        makeDataRequest(forCoordinates: location.coordinate)
    }
    
    public func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Something wrong: \(error.localizedDescription)")
    }
        
}



