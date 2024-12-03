//
//  PostDTO.swift
//  DogWalk
//
//  Created by junehee on 11/2/24.
//

import Foundation

// 게시글 조회 응답
struct PostResponseDTO: Decodable {
    let data: [PostDTO]
    let next_cursor: String
}
struct GeolocationPostResponseDTO: Decodable {
    let data: [PostDTO]
}

extension PostResponseDTO {
    func toDomain() -> PostResponseModel {
        return PostResponseModel(data: self.data.map { $0.toDomain() }, nextCursor: self.next_cursor)
    }
}

struct PostResponseModel {
    let data: [PostModel]
    let nextCursor: String
}
