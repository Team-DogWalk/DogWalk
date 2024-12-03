//
//  LastChatDTO.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 마지막 채팅 정보 응답 (Response)
struct LastChatDTO: Decodable {
    let chat_id: String
    let room_id: String
    let content: String?
    let sender: UserDTO
    let files: [String]
}

extension LastChatDTO {
    func toDomain() -> LastChatModel {
        let messageType: MessageType = self.content == nil ? .image : .text
        let lastChat = messageType == .image ? self.files.first ?? "" : self.content ?? ""
        return LastChatModel(type: messageType,
                             chatID: self.chat_id,
                             lastChat: lastChat,
                             sender: self.sender.toDomain())
    }
}

// MARK: 코어 데이터에서도 사용하는 타입!
enum MessageType: String {
    case text = "텍스트"
    case image = "이미지"
}

struct LastChatModel {
    let type: MessageType        // 메시지 종류 (텍스트 or 이미지)
    let chatID: String
    let lastChat: String
    let sender: UserModel
}
