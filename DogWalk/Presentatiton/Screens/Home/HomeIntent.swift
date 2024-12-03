//
//  HomeIntent.swift
//  DogWalk
//  Created by 김윤우 on 11/12/24.
//


import Foundation
import Combine


protocol HomeIntentProtocol {
    func onAppear()
    func fetchPostList() async
    func fetchWeatherData() async
    func profileButtonTap()
    func resetProfileButtonSate()
    func fetchProfile() async
}

final class HomeIntent {
    private weak var state: HomeIntentActionProtocol?
    private let useCase: HomeUseCase
    
    init(state: HomeIntentActionProtocol, useCase: HomeUseCase) {
        self.state = state
        self.useCase = useCase
    }
}

extension HomeIntent: HomeIntentProtocol {
 
    func onAppear() {
        state?.changeContentState(state: .loading)
    }
    
    func fetchPostList() async {
        do {
            let posts = try await useCase.getPostList()
            state?.updatePostList(posts: posts)
        }  catch {
            
        }
    }
    
    func profileButtonTap() {
        state?.updateProfileButtonSate(true)
    }
    
    func resetProfileButtonSate() {
        state?.updateProfileButtonSate(false)
    }
    func fetchProfile() async {
        do {
            let profile = try await useCase.fetchProfile()
//            dump(profile)
            state?.fetchProfile(profile: profile)
        } catch {
            
        }
        
    }
    
    func fetchWeatherData() async {
        do {
            // WeatherData 가져오기
            let weatherData = try await useCase.userWeatherData()
            // 상태 업데이트
            DispatchQueue.main.async {
                self.state?.getWeatherData(weatherData: weatherData)
            }
        } catch {
            // 에러 메시지 처리
            print("Failed to fetch weather data: \(error.localizedDescription)")
        }
    }
}
