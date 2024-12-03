//
//  PostChatFileBody.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 채팅방 파일 업로드 요청 (Request)
struct PostChatFileBody: Encodable {
    let files: [Data]
}
