//
//  Weather.swift
//  DogWalk
//
//  Created by 김윤우 on 11/19/24.
//

import WeatherKit
import CoreLocation

final class WeatherKitAPIManager {
    static let shared = WeatherKitAPIManager()
    private let weatherService = WeatherService.shared
    private init() { }
    
    // 현재 날씨 가져오기
    func fetchWeather(for location: CLLocation) async throws -> Weather {
        return try await weatherService.weather(for: location)
    }
}

