//
//  PutPostBody.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 게시글 수정 요청 (Request)
struct PutPostBody: Encodable {
    let category: String
    let title: String
    let price: Int
    let content: String
    let content1: String
    let content2: String
    let content3: String
    let content4: String
    let content5: String
    let files: [String]
    let longitude: Double
    let latitude: Double
}
