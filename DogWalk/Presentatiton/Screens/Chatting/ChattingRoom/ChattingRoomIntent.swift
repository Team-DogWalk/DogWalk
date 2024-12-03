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
    func sendTextMessage(roomID: String, text: String) async
    func sendImageMessage(roomID: String, image: UIImage) async
    func onDisappearTrigger()
    func onActiveTrigger(roomID: String)
    func onBackgroundTrigger()
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
        // print(chattingData)
        /// 2) 최근 대화 날짜 가져오기
        let cursorDate = useCase.getCursorDate(roomID: roomID)
        
        /// 3) 최근 대화 날짜 기반 새로운 대화 내역 요청
        Task {
            do {
                // let result = try await useCase.fetchChattingData(roomID: roomID, cursorDate: cursorDate)
                let result = try await useCase.fetchChattingData(roomID: roomID, cursorDate: "")
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
    // 파일 업로드 후 응답 데이터를 CoreData 저장
    func sendTextMessage(roomID: String, text: String) async {
        print(#function, "채팅 전송 버튼 클릭")
        Task {
            do {
                let chattingModel = try await useCase.sendMessage(roomID: roomID, type: .text, content: text)
                print("채팅 전송 완료")
                print(chattingModel)
                print("CoreData에 저장")
                useCase.updateChattingData(roomID: roomID, data: [chattingModel])
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
    func sendImageMessage(roomID: String, image: UIImage) async {
        print("1", #function)
        // print(image)
        Task {
            do {
                guard let jpegData = image.jpegData(compressionQuality: 10) else { return }
                let files = try await useCase.postChattingImage(roomID: roomID, image: jpegData) // files: [String]
                
                print("파일 잘 오니?", files)
                
                let result = try await useCase.sendMessage(roomID: roomID, type: .image, content: files.url.first ?? "")
                
                // fetchMessages123
                print("SendImageMessage RESULT", result)
                useCase.updateChattingData(roomID: roomID, data: [result])
                
                let newMessages = useCase.getAllChattingData(roomID: roomID)
                state?.updateChattingView(data: newMessages)
            } catch {
                print(#function, error)
                state?.changeViewState(state: .error)
            }
        }
    }
    
    // App Active 상태일 때
    func onActiveTrigger(roomID: String) {
        print(#function)
        // useCase.openSocket(roomID: roomID)
        useCase.reconnectSocket(roomID: roomID)
    }
    
    func onBackgroundTrigger() {
        print(#function)
        useCase.closeSocket()
    }
    
    // 채팅방 퇴장 or Background - Socket Close
    func onDisappearTrigger() {
        print(#function)
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
