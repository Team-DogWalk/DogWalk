//
//  ChattingRoomState.swift
//  DogWalk
//
//  Created by junehee on 11/12/24.
//

import Foundation
import Combine

protocol ChattingRoomStateProtocol {
    var viewState: CommonViewState { get }          // 화면 상태
    var roomID: String { get }                      // 채팅방 ID
    var chattingData: [ChattingModel] { get }       // 채팅방 채팅 내역
    var isSent: Bool { get }                        // 채팅 전송 완료 여부
}

protocol ChattingRoomActionProtocol: AnyObject {
    func changeViewState(state: CommonViewState)
    func updateChattingData(data: [ChattingModel])
}

@Observable
final class ChattingRoomState: ChattingRoomStateProtocol, ObservableObject {
    let roomID: String
    
    init(roomID: String) {
        self.roomID = roomID
    }
    
    var viewState: CommonViewState = .loading
    var chattingData: [ChattingModel] = []
    var isSent: Bool = false
}

extension ChattingRoomState: ChattingRoomActionProtocol {
    // 뷰 상태 변화
    func changeViewState(state: CommonViewState) {
        self.viewState = state
    }
    
    // 채팅 내역 최신화
    func updateChattingData(data: [ChattingModel]) {
        self.chattingData = data
    }
}
