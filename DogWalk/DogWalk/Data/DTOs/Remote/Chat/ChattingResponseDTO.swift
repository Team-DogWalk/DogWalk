//
//  ChattingRoomResponseDTO.swift
//  DogWalk
//
//  Created by junehee on 11/12/24.
//

import Foundation

// 채팅 내역 조회 응답 (Response)
/// 특정 채팅방에서 대화한 내역 리스트
struct ChattingResponseDTO: Decodable {
    let data: [ChattingDTO]
}

extension ChattingResponseDTO {
    func toDomain() -> [ChattingModel] {
        return self.data.map { $0.toDomain() }
    }
}
