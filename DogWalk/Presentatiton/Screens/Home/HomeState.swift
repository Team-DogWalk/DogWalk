//
//  HomeState.swift
//  DogWalk
//
//  Created by 김윤우 on 11/12/24.
//

import Foundation
import Combine


protocol HomeStateProtocol {
    var popularityDogWalkList: [PostModel] { get }  // 인기산책 인증 데이터
    var isProfileButtonTap: Bool { get }            // 프로필 버튼 트리거 변수
    var isHomeViewFirstInit: Bool { get }            // HomeView 첫 생성시에만 인기 산책인증 통신을 하기 위한 플래그 변수
    
}

protocol HomeIntentActionProtocol: AnyObject {
    func getPostList() async  // 인기 산책 인증 통신
    func profileButtonTap() // 프로필 버튼 화면 전환
    func isResetProfileButtonState()
    func isHomeViewFirstInitState() -> Bool
    func changeHomeViewInitState()
    func postDetailTap()
    
}

@Observable
final class HomeState: HomeStateProtocol, ObservableObject {
    
    var popularityDogWalkList: [PostModel] = []
    var isProfileButtonTap = false
    var isHomeViewFirstInit = true
    
    
    private let network = NetworkManager()
    private var cancellables = Set<AnyCancellable>()
    
}

extension HomeState: HomeIntentActionProtocol {
    
    func changeHomeViewInitState() {
        isHomeViewFirstInit = false
    }
    
    func isHomeViewFirstInitState() -> Bool {
        isHomeViewFirstInit
    }

    func isResetProfileButtonState() {
        isProfileButtonTap = false
    }
    
    func profileButtonTap() {
        isProfileButtonTap.toggle()
    }
    
    func postDetailTap() {
        
    }
    
    func getPostList() async {
        print("게시물 가지고오기")
        do {
            let query = GetPostQuery(next: "", limit: "15", category: ["산책인증"])
            let future = try await network.request(target: .post(.getPosts(query: query)), of: PostResponseDTO.self)
            future
                .sink { result in
                    switch result {
                    case .finished:
                        print("🗒️게시물 통신 성공")
                    case .failure(let error):
                        print("🚨게시물 통신 실패", error)
                    }
                } receiveValue: { [weak self] data in
                    guard let self else { return }
                    print("🔥 HomeState getPostList 함수 데이터",data)
                    let domain = data.toDomain()
                    self.updatePopularityList(with: domain.data)
                    isHomeViewFirstInit = false
                }
                .store(in: &cancellables)
        } catch {
            print("HomeState getPostList메서드 오류")
        }
    }
    
    // 조회수 기준 내림차순 정렬
    private func updatePopularityList(with posts: [PostModel]) {
        self.popularityDogWalkList = posts.sorted(by: { $0.views > $1.views })
    }
}
