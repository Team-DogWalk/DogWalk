//
//  LikePostBody.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 게시글 좋아요 요청 (Request)
struct LikePostBody: Encodable {
    let like_status: Bool
}
