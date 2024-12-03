//
//  GetChatListQuery.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 채팅 내역 조회 요청 (Request)
struct GetChatListQuery: Encodable {
    let cursor_date: String?
}
