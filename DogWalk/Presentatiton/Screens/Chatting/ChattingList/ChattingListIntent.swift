//
//  ChattingListIntent.swift
//  DogWalk
//
//  Created by junehee on 11/11/24.
//

import Foundation

protocol ChattingListIntentProtocol {
    func onAppearTrigger() async
    func inputSearchText(_ text: String)
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
    func inputSearchText(_ text: String) {
        state?.updateSearchText(text)
    }
    
//    func onAppearTrigger() async {
//        print(#function, "멍톡 화면 진입")
//        state?.changeViewState(state: .loading)
//        
//        do {
//            let chattingRooms = try await useCase.getChattingRoomList()
//            state?.updateChattingRoomList(data: chattingRooms)
//        } catch {
//            print(error)
//        }
//        
////         채팅방 목록 가져온 후 State 전달
//         Task {
//             do {
//                 let chattingList = try await useCase.getChattingRoomList()
//                 state?.updateChattingRoomList(data: chattingList)
//                 state?.changeViewState(state: .content)
//             } catch {
//                 print(#function, error)
//                 state?.changeViewState(state: .error)
//             }
//         }
//    }
    func onAppearTrigger() async {
        print(#function, "멍톡 화면 진입")
        
        // 화면 상태를 로딩 상태로 변경
        state?.changeViewState(state: .loading)
        
        do {
            // 채팅방 목록 가져오기
            let chattingRooms = try await useCase.getChattingRoomList()
            
            // 상태 업데이트
            state?.updateChattingRoomList(data: chattingRooms)
            state?.changeViewState(state: .content) // 콘텐츠 상태로 전환
        } catch {
            print(#function, error)
            state?.changeViewState(state: .error) // 에러 상태로 전환
        }
    }
}
