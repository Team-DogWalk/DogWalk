//
//  ChattingDTO.swift
//  DogWalk
//
//  Created by junehee on 11/12/24.
//

import Foundation

// 채팅 내역 응답 (Response)
// 특정 채팅방에서 대화한 채팅 1개에 대한 정보
struct ChattingDTO: Decodable {
    let chat_id: String
    let room_id: String
    let content: String?
    let createdAt: String
    let sender: UserDTO
    let files: [String]
}

extension ChattingDTO {
    func toDomain() -> ChattingModel {
        let messageType: MessageType = self.content == nil ? .image : .text
        return ChattingModel(chatID: self.chat_id,
                             roomID: self.room_id,
                             type: messageType,
                             content: self.content ?? "",
                             createdAt: self.createdAt,
                             sender: UserModel(userID: self.sender.user_id ?? "",
                                               nick: self.sender.nick ?? "익명",
                                               profileImage: self.sender.profileImage ?? ""),
                             files: self.files)
    }
}

// View에서 ForEach 반복문에 id 필요하기 때문에 프로토콜 채택
struct ChattingModel: Equatable, Identifiable  {
    static func == (lhs: ChattingModel, rhs: ChattingModel) -> Bool {
        return false
    }
    
    let id = UUID()
    let chatID: String                  // 채팅 ID
    let roomID: String                  // 채팅방 ID
    let type: MessageType               // 채팅 내용이 텍스트인지 사진인지
    let content: String                 // 채팅 내용
    let createdAt: String               // 채팅 보낸 시간
    let sender: UserModel               // 채팅 보낸 사람
    let files: [String]                 // 이미지 파일
}

// 파일 업로드 후 받아오는 응답값
struct ChattingFilesModel: Decodable {
    let files: [String]
}
