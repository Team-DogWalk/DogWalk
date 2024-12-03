//
//  ChattingListState.swift
//  DogWalk
//
//  Created by junehee on 11/11/24.
//

import Foundation
import Combine

protocol ChattingListStateProtocol {
    var viewState: CommonViewState { get }                  // 화면 상태
    var chattingRoomList: [ChattingRoomModel] { get }       // 채팅방 목록
}

protocol ChattingListActionProtocol: AnyObject {
    func changeViewState(state: CommonViewState)
    func updateChattingRoomList(data: [ChattingRoomModel])
}

@Observable
final class ChattingListState: ChattingListStateProtocol, ObservableObject {
    var viewState: CommonViewState = .loading
    var chattingRoomList: [ChattingRoomModel] = []
}

extension ChattingListState: ChattingListActionProtocol {
    func changeViewState(state: CommonViewState) {
        self.viewState = state
    }
    
    func updateChattingRoomList(data: [ChattingRoomModel]) {
        self.chattingRoomList = data
    }
}
