//
//  ChattingListUseCase.swift
//  DogWalk
//
//  Created by junehee on 11/19/24.
//

import Foundation

/**
 채팅방 리스트 (채팅 탭)
 
 1) 멍톡 탭 진입 시 DB에 저장된 모든 채팅방 정보 불러오기
 2) 서버에 모든 채팅방 정보 호출 후 DB에 lastChat 정보 업데이트
 3) 업데이트된 최신 채팅방 정보를 화면에 렌더링 (updateAt을 기준으로 정렬)
 (서버가 끊겨도 멍톡 탭에서 채팅방 리스트를 보여주고, 채팅방 눌렀을 때도 이전 데이터를 계속 보여주기 위함.)
 */
protocol ChattingListUseCase {
    func getChattingRoomList() async throws -> [ChattingRoomModel]
}

final class DefaultChattingListUseCase: ChattingListUseCase {
    private let network = NetworkManager()
    private let chatRepository = ChatRepository.shared
    
    // DB에서 채팅방 목록 가져오기
    func getChattingRoomList() async throws -> [ChattingRoomModel] {
        // 1) DB에 저장된 모든 채팅방 가져오기
        // print("기존에 저장된 모든 채팅방 정보")
        // dump(chatRepository.fetchAllChatRoom() ?? [])
        
        // 2) 서버에서 모든 채팅방 정보 가져와 lastChat 정보 업데이트
        do {
            let DTO = try await network.requestDTO(target: .chat(.getChatRoomList), of: ChattingRoomListResponseDTO.self)
            let chattingRooms = DTO.toDomain()
            chattingRooms.forEach { chattingRoom in
                chatRepository.createChatRoom(chatRoomData: chattingRoom)
            }
            return chatRepository.fetchAllChatRoom() ?? []
        } catch {
            print(#function, "채팅방 목록 서버 요청 실패")
            throw error
        }
    }
   
}
