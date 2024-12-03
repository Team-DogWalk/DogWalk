//
//  ChatRoomResponseDTO.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 채팅방 리스트 조회 응답 (Response)
/// 채팅 탭에서 보여지는 내가 참여한 채팅방 리스트
struct ChattingRoomListResponseDTO: Decodable {
    let data: [ChattingRoomDTO]
}

extension ChattingRoomListResponseDTO {
    func toDomain() -> [ChattingRoomModel] {
        return self.data.map { $0.toDomain() }
    }
}
