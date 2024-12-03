//
//  PostFileBody.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 파일 업로드 요청 (Request)
struct PostFileBody: Encodable {
    let files: [Data]?
}
