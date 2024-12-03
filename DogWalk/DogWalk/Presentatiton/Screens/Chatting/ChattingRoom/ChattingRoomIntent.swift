//
//  ChattingRoomIntent.swift
//  DogWalk
//
//  Created by junehee on 11/12/24.
//

import SwiftUI
import Combine

protocol ChattingRoomIntentProtocol {
    func onAppearTrigger(roomID: String)
    func sendTextMessage(roomID: String, message: String) async
    func onDisappearTrigger()
}

final class ChattingRoomIntent {
    private weak var state: ChattingRoomActionProtocol?
    private var useCase: ChattingRoomUseCase
    private let chatRepoTest = ChatRepository.shared
    private var cancellable = Set<AnyCancellable>()
    init(state: ChattingRoomActionProtocol, useCase: ChattingRoomUseCase) {
        self.state = state
        self.useCase = useCase
    }
}

extension ChattingRoomIntent: ChattingRoomIntentProtocol {
    // 채팅방 입장
    func onAppearTrigger(roomID: String) {
        print(#function, "멍톡 채팅방 진입")
        state?.changeViewState(state: .loading)
        
        /// 1) DB에서 기존 대화 내역 가져와서 저장
        let chattingData = useCase.getChattingData(roomID: roomID)
        state?.updateChattingView(data: chattingData)
        
        /// 2) 최근 대화 날짜 가져오기
        let cursorDate = useCase.getCursorDate(roomID: roomID)

        
        /// 3) 최근 대화 날짜 기반 새로운 대화 내역 요청
        Task {
            do {
                let result = try await useCase.fetchChattingData(roomID: roomID, cursorDate: cursorDate)
                /// 3) 응답 받은 채팅 데이터를 DB 저장
                useCase.updateChattingData(roomID: roomID, data: result)
                /// 4) DB에 저장된 전체 채팅 데이터 가져온 후 State 전달
                let chattingData = useCase.getAllChattingData(roomID: roomID)
                state?.updateChattingView(data: chattingData)
                /// 5) Socket 연결
                useCase.openSocket(roomID: roomID)
                recieve()
            } catch  {
                print(#function, error)
                state?.changeViewState(state: .error)
            }
        }
        
        
    }
    
    // 텍스트 메세지 전송
    func sendTextMessage(roomID: String, message: String) async {
        print(#function, "채팅 전송 버튼 클릭")
        Task {
            do {
                let result = try await useCase.sendTextMessage(roomID: roomID, message: message)
                print("채팅 전송 완료")
                print(result)
                print("CoreData에 저장")
                useCase.updateChattingData(roomID: roomID, data: [result])
                print("전체 메세지 다시 가져와서 뷰에 띄움")
                let newMessages = useCase.getAllChattingData(roomID: roomID)
                state?.updateChattingView(data: newMessages)
            } catch  {
                print(#function, error)
                state?.changeViewState(state: .error)
            }
        }
    }
    
    // 이미지 메세지 전송
    func sendImageMessage(roomID: String, image: UIImage) {
        Task {
            do {
                guard let jpegData = image.jpegData(compressionQuality: 10) else { return }
                let result = try await useCase.sendImageMessage(roomID: roomID, image: jpegData)
                print(result)
            } catch {
                print(#function, error)
            }
        }
    }
    
    // 채팅방 퇴장 - Socket Close
    func onDisappearTrigger() {
        // 이 시점에서 ChattingList LastChat 업데이트 해주기
        useCase.closeSocket()
    }
    
    
    func recieve() {
        useCase.chattingSubject
            .sink { chattingData in
                print("chattingData", chattingData)
                self.state?.updateChattingView(data: chattingData)
            }
            .store(in: &cancellable)
    }
}
