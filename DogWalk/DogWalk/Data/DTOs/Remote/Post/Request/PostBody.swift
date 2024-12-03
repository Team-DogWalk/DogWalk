//
//  PostBody.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 게시글 작성 요청 (Request)
struct PostBody: Encodable {
    let category: String
    let title: String
    let price: Int
    let content: String
    let files: [String]
    let longitude: Double
    let latitude: Double
}
