//
//  LikePostDTO.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 게시글 좋아요 응답
struct LikePostDTO: Decodable {
    let like_status: Bool
}

extension LikePostDTO {
    func toDomain() -> LikePostModel {
        return LikePostModel(likeStatus: self.like_status)
    }
}

struct LikePostModel {
    let likeStatus: Bool
}
