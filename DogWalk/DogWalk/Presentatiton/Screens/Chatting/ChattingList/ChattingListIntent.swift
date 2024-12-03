//
//  ChattingListIntent.swift
//  DogWalk
//
//  Created by junehee on 11/11/24.
//

import Foundation

protocol ChattingListIntentProtocol {
    func onAppearTrigger() async
}

// 채팅방 리스트
final class ChattingListIntent {
    private weak var state: ChattingListActionProtocol?
    private var useCase: ChattingListUseCase
    
    init(state: ChattingListActionProtocol, useCase: ChattingListUseCase) {
        self.state = state
        self.useCase = useCase
    }
}

extension ChattingListIntent: ChattingListIntentProtocol {
    func onAppearTrigger() async {
        print(#function, "멍톡 화면 진입")
        state?.changeViewState(state: .loading)
        
        do {
            let chattingRooms = try await useCase.getChattingRoomList()
            state?.updateChattingRoomList(data: chattingRooms)
        } catch {
            print(error)
        }
        
        // 채팅방 목록 가져온 후 State 전달
        // Task {
        //     do {
        //         let chattingList = try await useCase.getChattingRoomList()
        //         state?.updateChattingRoomList(data: chattingList)
        //         state?.changeViewState(state: .content)
        //     } catch {
        //         print(#function, error)
        //         state?.changeViewState(state: .error)
        //     }
        // }
    }
}
