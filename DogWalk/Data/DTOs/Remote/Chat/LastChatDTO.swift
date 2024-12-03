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
        // 채팅방 리스트
        let messageType: MessageType = !(self.files.first?.isEmpty ?? true) ? .image : .text
        let lastChat: String
        
        if messageType == .image {
            lastChat = self.files.first ?? "사진" // 파일이 없으면 "[이미지]"로 표시
        } else {
            lastChat = self.content ?? "" // 텍스트가 없으면 "메시지 없음"으로 표시
        }
        
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
    let type: MessageType  // 메시지 종류 (텍스트 or 이미지)
    let chatID: String
    let lastChat: String
    let sender: UserModel
}
