//
//  SendChatBody.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 채팅 메세지 보내기 요청 (Request)
struct SendChatBody: Encodable {
    let content: String
    let files: [String]
}
