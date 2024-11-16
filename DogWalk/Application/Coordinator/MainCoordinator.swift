//
//  CoordinatorImpl.swift
//  DogWalk
//
//  Created by 김윤우 on 11/8/24.
//

import SwiftUI

final class MainCoordinator: DogWalkCoordinatorProtocol {
    @Published var path: NavigationPath = NavigationPath()
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    @Published var selectedTab: Tab?
    
    func push(_ screen: Screen) {
        path.append(screen)
    }
    
    func presentSheet(_ sheet: Sheet) {
        path.append(sheet)
    }
    
    func presentFullScreenCover(_ fullScreenCover: FullScreenCover) {
        path.append(fullScreenCover)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count) // 빈 배열로 초기화시 RootView
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
    
    func dismissFullScreenOver() {
        self.fullScreenCover = nil
    }
    
    // 화면
    @ViewBuilder
    func build(_ screen: Screen) -> some View {
        switch screen {
        case .tab: CustomTabView()                      // 탭
        case .auth: AuthView()                          // 회원가입
        case .login: LoginView.build()                  // 로그인
        case .home: HomeView.build()                    // 홈
        case .map: MapView.build()                      // 산책하기 탭 첫
        case .dogWalkResult: WalkResultView.build()     // 산책 결과
        case .communityCreate: CommunityCreateView()    // 게시글 작성
        case .community: CommunityView.build()          // 커뮤니티 리스트 화면
        case .communityDetail: CommunityDetailView()    // 커뮤니티 게시글 디테일
        case .chatting: ChattingListView.build()        // 채팅방 리스트 화면
        case .chattingRoom: ChattingRoomView()          // 채팅방
        case .setting: SettingView()                    // 세팅
        }
    }
    
    // 시트
    @ViewBuilder
    func build(_ sheet: Sheet) -> some View {
        //MARK: 추가 구현시 예시 실제 사용시 삭제하고 사용하시면 됩니다.
//        switch sheet {
//        case .dogProfile(let dogID): DogProfileView(dogID: dogID)
//        }
    }
    
    // 풀스크린 커버
    @ViewBuilder
    func build(_ fullScreenCover: FullScreenCover) -> some View {
        //MARK: 추가 구현시 예시 실제 사용시 삭제하고 사용하시면 됩니다.
//        switch fullScreenCover {
//        case .dogWalkResult: WalkResultView.build()
//        }
    }
}
