//
//  HomeUseCase.swift
//  DogWalk
//
//  Created by 김윤우 on 11/18/24.
//

import Foundation
import Combine
import WeatherKit
import CoreLocation

protocol HomeUseCase {
    func getPostList() async throws -> [PostModel]
    func getUserLocationWeather() async throws -> Weather
    func userWeatherData() async throws ->WeatherData
}

final class HomeViewUseCase: HomeUseCase {
    private let network = NetworkManager()
    private let userManager = UserManager.shared
    private let weatherManager = WeatherKitAPIManager.shared
    
    func getPostList() async throws  -> [PostModel] {
        let query = GetPostQuery(next: "", limit: "15", category: ["산책인증"])
        let response = try await network.requestDTO(target: .post(.getPosts(query: query)), of: PostResponseDTO.self)
        let domain = response.toDomain()
        return domain.data
    }
    
    func getUserLocationWeather() async throws -> Weather{
        let weather = CLLocation(latitude: userManager.lat, longitude: userManager.lon)
        return try await weatherManager.fetchWeather(for: weather)
    }
    
    func userWeatherData() async throws -> WeatherData {
        let userLocation = CLLocation(latitude: userManager.lat, longitude: userManager.lon)
        
        async let address = userLocation.toAddress()
        async let weather = getUserLocationWeather()
        let translateweather = try await translateCondition(weather.currentWeather.condition)
        
        await print(try address)
        await print(try weather)
        print("Weather condition: \(try await weather.currentWeather.condition)")
        
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

struct WeatherData {
    let weather: String
    let userAddress: String
}
