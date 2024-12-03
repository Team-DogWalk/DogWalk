//
//  DogWalkCoordinatorProtocol.swift
//  DogWalk
//
//  Created by 김윤우 on 11/8/24.
//

import SwiftUI

protocol DogWalkCoordinatorProtocol: ObservableObject {
    var path: NavigationPath { get set }
    var sheet: Sheet? { get set }
    var fullScreenCover: FullScreenCover? { get set }
    
    func push(_ screen: Screen) // 다음 화면 이동
    func presentSheet(_ sheet: Sheet) // 시트 띄우기
    func presentFullScreenCover(_ fullScreenCover: FullScreenCover) // 풀스크린커버 띄우기
    func pop() // 이전 뷰로 이동
    func popToRoot() // 홈화면으로 이동
    func dismissSheet() // 시트 내리기
    func dismissFullScreenOver() // 풀스크린 커버 내리기
    
}

//MARK: 필요한 뷰 추가해서 사용
//MARK: 값전달이 필요하면 필요한 파라미터 정의해서 사용. ex) postDetail 케이스
enum Screen: Identifiable, Hashable {
    var id: Self { return self } //  각 케이스가 자신을 반환하여  고유하게 식별됨
    
    // 로그인 , 홈탭
    case auth   // 회원가입
    case login  // 로그인 뷰
    case home   // 홈 뷰
    case tab
    
    // 산책하기 탭
    case map                // 산책하기 탭 첫 화면
    case dogWalkResult(walkTime: Int, walkDistance: Double, routeImage: UIImage)      // 산책 결과 화면
    case mapCommunityCreate(walkTime: Int, walkDistance: Double, walkCalorie: Double, walkImage: UIImage)    // 산책 게시글 작성 화면
    
    // 커뮤니티 탭
    case community
    case communityDetail(postID: String)
    case communityCreate    // 게시글 작성 화면
    
    // 채팅 탭
    case chatting
    case chattingRoom(roomID: String)
    
    // 설정 (추후 구현시 추가)
    case setting
    
    
}

// 탭 뷰
enum Tab: Identifiable, Hashable {
    var id: Self { return self }
    
    case home
    case dogWalk
    case community
    case chatting
    
}
//MARK: 필요한 뷰 추가해서 사용
enum Sheet: Identifiable, Hashable {
    var id: Self { return self } 
    
    case dogProfile(dogID: String) // 강아지 프로필 시트
}


//MARK: 필요한 뷰 추가해서 사용
enum FullScreenCover:  Identifiable, Hashable {
    var id: Self { return self }
    
    case dogWalkResult(walkTime: Int, walkDistance: Double, routeImage: UIImage)
}
