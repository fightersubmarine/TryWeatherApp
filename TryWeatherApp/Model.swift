//
//  ViewModel.swift
//  TryWeatherApp
//
//  Created by Александр on 26.12.2023.
//

import Foundation

public struct Weather {
    let city: String
    let today: DailyForecast
    let forecastDays: [ForecastDay]

    init(response: ApiResponse) {
        self.city = response.city.name
        self.today = DailyForecast(forecast: response.list[0])
        self.forecastDays = response.list.dropFirst().map { ForecastDay(forecast: $0) }
    }
}

public struct ForecastDay {
    let date: String
    let temperature: String
    let description: String
    let iconName: String
    let windSpeed: String

    init(forecast: ApiForecast) {
        self.date = "\(forecast.dt)"
        self.temperature = String(forecast.main.temp)
        self.description = forecast.weather.first?.description ?? ""
        self.iconName = forecast.weather.first?.iconName ?? ""
        self.windSpeed = String(forecast.wind.speed)
    }
}

public struct DailyForecast {
    let date: Date
    let temperature: String
    let description: String
    let iconName: String
    let windSpeed: String

    init(forecast: ApiForecast) {
        self.date = Date(timeIntervalSince1970: forecast.dt)
        self.temperature = String(forecast.main.temp)
        self.description = forecast.weather.first?.description ?? ""
        self.iconName = forecast.weather.first?.iconName ?? ""
        self.windSpeed = String(forecast.wind.speed)
    }
}
