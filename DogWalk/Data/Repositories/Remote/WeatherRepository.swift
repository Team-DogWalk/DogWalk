//
//  WeatherRepository.swift
//  DogWalk
//
//  Created by 박성민 on 12/2/24.
//

import Foundation
import WeatherKit
import CoreLocation

protocol WeatherRepository {
    func getUserLocationWeather() async throws -> Weather
    func userWeatherData() async throws -> WeatherData
}

final class DefaultWeatherRepository: WeatherRepository {
    private let weatherManager = WeatherKitAPIManager.shared
    private let userManager = UserManager.shared
    
    func getUserLocationWeather() async throws -> Weather {
        let weather = CLLocation(latitude: userManager.lat, longitude: userManager.lon)
        return try await weatherManager.fetchWeather(for: weather)
    }
    func userWeatherData() async throws -> WeatherData {
        let userLocation = CLLocation(latitude: userManager.lat, longitude: userManager.lon)
        
        async let address = userLocation.toAddress()
        async let weather = getUserLocationWeather()
        let translateweather = try await translateCondition(weather.currentWeather.condition)
        
        let (fetchedAddress, _) = try await (address, translateweather)
        return WeatherData(weather: translateweather, userAddress: fetchedAddress)
    }
    private func translateCondition(_ condition: WeatherCondition) -> String {
        switch condition {
        case .clear:
            return "맑음"
        case .mostlyClear:
            return "대체로 맑음"
        case .partlyCloudy:
            return "부분적으로 흐림"
        case .mostlyCloudy:
            return "대체로 흐림"
        case .cloudy:
            return "흐림"
        case .haze:
            return "실안개"
        case .drizzle:
            return "이슬비"
        case .rain:
            return "비"
        case .snow:
            return "눈"
        case .sleet:
            return "진눈깨비"
        case .hail:
            return "우박"
        case .freezingRain:
            return "어는 비"
        case .hurricane:
            return "허리케인"
        case .tropicalStorm:
            return "열대 폭풍"
        default:
            return "알 수 없음"
        }
    }
}
