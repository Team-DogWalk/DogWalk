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
    var nick: String { get }                        // 채팅방 이름 (= 상대방 닉네임)
    var chattingData: [ChattingModel] { get }       // 채팅방 채팅 내역
    var isSent: Bool { get }                        // 채팅 전송 완료 여부
}

protocol ChattingRoomActionProtocol: AnyObject {
    func changeViewState(state: CommonViewState)
    func updateChattingView(data: [ChattingModel])
}

@Observable
final class ChattingRoomState: ChattingRoomStateProtocol, ObservableObject {
    let roomID: String
    let nick: String        // 대화하는 상대방 닉네임
    
    init(roomID: String, nick: String) {
        self.roomID = roomID
        self.nick = nick
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
    func updateChattingView(data: [ChattingModel]) {
        self.chattingData = data
    }
}
