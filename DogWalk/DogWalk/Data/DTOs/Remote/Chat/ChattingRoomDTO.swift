//
//  ChatRoomDTO.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 채팅방 정보 응답 (Response)
// 하나의 채팅방에 대한 정보
struct ChattingRoomDTO: Decodable {
    let room_id: String
    let createdAt: String
    let updatedAt: String
    let participants: [UserDTO]
    let lastChat: LastChatDTO?
}

extension ChattingRoomDTO {
    func toDomain() -> ChattingRoomModel {
        let userID = UserManager.shared.userID
        let me = self.participants.filter { $0.user_id == userID }.first ?? UserDTO(user_id: "", nick: "나", profileImage: "")
        let otherUser = self.participants.filter() { $0.user_id != userID }.first ?? UserDTO(user_id: "", nick: "알 수 없음", profileImage: "")    // 사용자가 2명 이상일 경우 변경 필요
        
        return ChattingRoomModel(roomID: self.room_id,
                             createAt: self.createdAt,
                             updatedAt: self.updatedAt,
                             me: me.toDomain(),
                             otherUser: otherUser.toDomain(),
                             lastChat: self.lastChat?.toDomain())
    }
}

// 실제 사용할 모델
struct ChattingRoomModel {
    let roomID: String                  // 채팅방 ID
    let createAt: String                // 채팅방 생성일
    let updatedAt: String               // 채팅방 수정일 (마지막 메세지)
    let me: UserModel                   // 나
    let otherUser: UserModel            // 상대방 (채팅방 참여자)
    let lastChat: LastChatModel?        // 마지막 채팅 정보
}
