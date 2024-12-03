//
//  CommunityState.swift
//  DogWalk
//
//  Created by 박성민 on 11/12/24.
//

import Foundation

// MARK: - 데이터 관련 프로토콜
protocol CommunityStateProtocol { // 속성들을 가지는 프토코롤
    var contentState: ContentState { get } // 뷰 상태
    var postList: [PostModel] { get } //게시글들
    var categorys: [CommunityCategoryType] { get } //필터 버튼
    var selectCategory: CommunityCategoryType { get } // 선택한 필터
    var area: CheckPostType { get } // 유저가 선택한 위치
    //var errTitle: String { get }
}

protocol CommunityActionProtocol: AnyObject { //메서드을 가지고있는 프로토콜
    func getPosts(_ posts: [PostModel]) //게시글
    func changeSelectCategory(_ select: CommunityCategoryType) //카테고리 변경
    func changeArea(_ area: CheckPostType) //위치 설정
    func changeContentState(state: ContentState)
    func postPageNation(_ posts: [PostModel])
}
// MARK: - view에게 전달할 데이터
@Observable
final class CommunityState: CommunityStateProtocol, ObservableObject {
    var contentState: ContentState = .loading
    var postList: [PostModel] = []
    var categorys: [CommunityCategoryType] = CommunityCategoryType.allCases
    var selectCategory: CommunityCategoryType = .all
    var area: CheckPostType = .all
    //var errTitle: String = "" //에러 얼럿
}

// MARK: - intent에 줄 함수
extension CommunityState: CommunityActionProtocol {
    
    //뷰 상태 변화
    func changeContentState(state: ContentState) {
        self.contentState = state
    }
    //카테고리 변경
    func changeSelectCategory(_ select: CommunityCategoryType) {
        self.selectCategory = select
    }
    //위치 vs 전체
    func changeArea(_ area: CheckPostType) {
        self.area = area
    }
    //포스트 가져오기
    func getPosts(_ posts: [PostModel]) {
        self.postList = posts
    }
    //페이지네이션 포스트 가져오기
    func postPageNation(_ posts: [PostModel]) {
        self.postList.append(contentsOf: posts)
    }
    
}


