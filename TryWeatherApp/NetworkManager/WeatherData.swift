//
//  WeatherData.swift
//  TryWeatherApp
//
//  Created by Александр on 29.12.2023.
//

import Foundation

struct ApiResponse: Decodable {
    let city: ApiCity
    let list: [ApiForecast]
}

struct ApiCity: Decodable {
    let name: String
}

struct ApiForecast: Decodable {
    let dt: TimeInterval
    let main: ApiMain
    let wind: ApiWind
    let weather: [ApiWeather]
}

struct ApiWind: Decodable {
    let speed: Double
}

struct ApiMain: Decodable {
    let temp: Double
}

struct ApiWeather: Decodable {
    let description: String
    let iconName: String
    
    enum CodingKeys: String, CodingKey {
        case description
        case iconName = "main"
    }
}

