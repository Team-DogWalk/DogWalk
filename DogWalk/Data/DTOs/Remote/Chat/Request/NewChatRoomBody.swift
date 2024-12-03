//
//  NewChatRoomBody.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 새로운 채팅방 생성 요청 (Request)
struct NewChatRoomBody: Encodable {
    let opponent_id: String
}
