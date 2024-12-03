//
//  CommentDTO.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 게시글 댓글 응답 (Response)
struct CommentDTO: Decodable {
    let comment_id: String
    let content: String?
    let createdAt: String?
    let creator: UserDTO?
}

extension CommentDTO {
    func toDomain() -> CommentModel {
        return CommentModel(commentID: self.comment_id,
                            content: self.content ?? "",
                            createdAt: self.createdAt ?? "",
                            creator: self.creator?.toDomain() ?? UserModel(userID: "", nick: "", profileImage: ""))
    }
}

struct CommentModel {
    let commentID: String
    let content: String
    let createdAt: String
    let creator: UserModel
}
