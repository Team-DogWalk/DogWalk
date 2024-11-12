//
//  PostDTO.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 게시글 상세 응답
struct PostDTO: Decodable {
    let post_id: String
    let category: String
    let title: String
    let price: Int
    let content: String
    let createdAt: String
    let creator: UserDTO
    let files: [String]
    let likes: [String]         // 게시글 좋아요한 사람 목록
    let views: [String]         // 게시글 방문한 사람 목록
    let hashTags: [String]
    let comments: [CommentDTO]
    let geolocation: GeolocationDTO
    let distance: Double
}

extension PostDTO {
    func toDomain() -> PostModel {
        return PostModel(postID: self.post_id,
                         created: self.createdAt.getFormattedDateString(),
                         category: CommunityCategoryType(rawValue: self.category) ?? .free,   // 매칭되는 카테고리 없을 시 자유게시판
                         title: self.title,
                         price: self.price,
                         content: self.content,
                         creator: UserModel(userID: self.creator.user_id, 
                                            nick: self.creator.nick, 
                                            profileImage: self.creator.profileImage ?? ""),
                         files: self.files,
                         likes: self.likes,
                         views: self.likes.count,
                         hashTags: self.hashTags,
                         comments: self.comments.map { CommentModel(commentID: $0.comment_id, 
                                                                    content: $0.content,
                                                                    createdAt: $0.createdAt, 
                                                                    creator: UserModel(userID: creator.user_id, 
                                                                                       nick: creator.nick,
                                                                                       profileImage: $0.creator.profileImage ?? ""))},
                         geolocation: GeolocationModel(lat: self.geolocation.latitude,
                                                       lon: self.geolocation.longitude),
                         distance: self.distance)
    }
}

// 커뮤니티 게시물 카테고리
enum CommunityCategoryType: String, CaseIterable {
    case all = "전체보기"
    case walkCertification = "산책인증"
    case question = "궁금해요"
    case shop = "중고용품"
    case sitter = "펫시터 구하기"
    case free = "자유게시판"
}

struct PostModel {
    let postID: String
    let created: String
    let category: CommunityCategoryType
    let title: String
    let price: Int
    let content: String
    let creator: UserModel
    let files: [String]
    let likes: [String]                     // 게시글 좋아요한 사람 목록
    let views: Int                          // 게시글 방문한 사람 카운팅
    let hashTags: [String]
    let comments: [CommentModel]
    let geolocation: GeolocationModel
    let distance: Double                    // 유저와 포스트의 거리
}

/**
 `distace`: 요청 쿼리의 위경도인 위치 기준으로 조회된 게시글의 위경도의 위치가 얼마나 떨어져있는지 의미. (미터단위)
 */
