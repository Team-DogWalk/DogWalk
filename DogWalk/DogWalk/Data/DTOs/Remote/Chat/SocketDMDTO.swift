//
//  SocketDMDTO.swift
//  DogWalk
//
//  Created by junehee on 11/18/24.
//

import Foundation

// 채팅 소켓 응답 (Response)
struct SocketDMDTO: Encodable, Decodable {
    let chat_id: String
    let room_id: String
    let content: String
    let createdAt: String
    let files: [String]
    let sender: UserDTO
}

extension SocketDMDTO {
    func toDomain() -> SocketDMModel {
        return SocketDMModel(chatID: self.chat_id,
                             roomID: self.room_id,
                             content: self.content,
                             createdAt: self.createdAt,
                             files: self.files,
                             sender: UserModel(userID: self.sender.user_id ?? "",
                                             nick: self.sender.nick ?? "익명",
                                             profileImage: self.sender.profileImage ?? ""))
    }
}

struct SocketDMModel: Encodable {
    let chatID: String
    let roomID: String
    let content: String
    let createdAt: String
    let files: [String]
    let sender: UserModel
}

/* 응답 예시
 {
     "chat_id" = 6740369b3a36e82f532ec721;
     content = "\Ub2e4\Uc74c \Ud2b9\Uac15\Uc740 \Uc5b4\Ub5a4 \Uc8fc\Uc81c\Ub85c \Ub4e3\Uace0\Uc2f6\Uc73c\Uc2e0\Uac00\Uc694??";
     createdAt = "2024-11-22T07:45:31.693Z";
     files =     (
     );
     "room_id" = 6731a3122cced3080560f671;
     sender =     {
         nick = "\Uc7ad\Uc7ad\Uc774";
         "user_id" = 67316ba02cced3080560f620;
     };
 }
*/
