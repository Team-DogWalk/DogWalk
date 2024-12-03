//
//  CommunityDetailState.swift
//  DogWalk
//
//  Created by 박성민 on 11/19/24.
//

import Foundation

// MARK: - 데이터 관련 프로토콜
protocol CommunityDetailStateProtocol { // 속성들을 가지는 프토코롤
    var contentState: ContentState { get } // 뷰 상태
    var post: PostModel { get } // 포스터
    var isLike: Bool { get } // 좋아요 유무
}

protocol CommunityDetailActionProtocol: AnyObject { //메서드을 가지고있는 프로토콜
    func changeState(state: ContentState) //화면 상태
    func getPost(isLike: Bool, post: PostModel) //디테일 포스터 가져오기
    func getContent(content: CommentModel) // 댓글 입력
    func getLike(isLike: Bool) // 좋아요 토글
    
}
// MARK: - view에게 전달할 데이터
@Observable
final class CommunityDetailState: CommunityDetailStateProtocol, ObservableObject {
    var contentState: ContentState = .loading
    var post: PostModel = PostModel()
    var isLike: Bool = false
}

// MARK: - intent에 줄 함수
extension CommunityDetailState: CommunityDetailActionProtocol {
    func changeState(state: ContentState) {
        self.contentState = state
    }
    
    func getPost(isLike: Bool, post: PostModel) {
        self.post = post
        self.isLike = isLike
    }
    
    func getContent(content: CommentModel) {
        self.post.comments.append(content)
    }
    
    func getLike(isLike: Bool) {
        self.isLike = isLike
    }
}

