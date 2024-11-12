//
//  ChattingRoomDTO.swift
//  DogWalk
//
//  Created by junehee on 11/12/24.
//

import Foundation

// 체팅 내역 응답 (Response)
struct ChattingRoomDTO: Decodable {
    let chat_id: String
    let room_id: String
    let content: String
    let sender: UserDTO
    let files: [String]
}

extension ChattingRoomDTO {
    func toDomain() -> ChattingRoomModel {
        return ChattingRoomModel(chatID: self.chat_id,
                                 roomID: self.room_id,
                                 content: self.content,
                                 sender: UserModel(userID: self.sender.user_id,
                                                   nick: self.sender.nick,
                                                   profileImage: self.sender.profileImage ?? ""),
                                 files: self.files)
    }
}

struct ChattingRoomModel {
    let chatID: String                  // 채팅 ID
    let roomID: String                  // 채팅방 ID
    let content: String                 // 채팅 내용
    let sender: UserModel               // 채팅 보낸 사람
    let files: [String]                 // 마지막 채팅 정보
}
