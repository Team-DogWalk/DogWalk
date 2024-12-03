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
    var searchText: String { get }
    var defaultRoomList: [ChattingRoomModel] { get }
}

protocol ChattingListActionProtocol: AnyObject {
    func changeViewState(state: CommonViewState)
    func updateChattingRoomList(data: [ChattingRoomModel])
    func updateSearchText(_ text: String)
}

@Observable
final class ChattingListState: ChattingListStateProtocol, ObservableObject {
    var viewState: CommonViewState = .loading
    var chattingRoomList: [ChattingRoomModel] = []
    var searchText: String = ""
    var defaultRoomList: [ChattingRoomModel] = []
}

extension ChattingListState: ChattingListActionProtocol {
    func changeViewState(state: CommonViewState) {
        self.viewState = state
    }
    
    func updateChattingRoomList(data: [ChattingRoomModel]) {
        self.chattingRoomList = data
        self.defaultRoomList = data
    }
    //검색어에 따른 채팅 리스트 필터링
    func updateSearchText(_ text: String) {
        self.searchText = text
        if text.isEmpty {
            self.chattingRoomList = defaultRoomList
        } else {
            self.chattingRoomList = defaultRoomList.filter { room in
                guard let chat = room.lastChat else {
                    return room.otherUser.nick.localizedCaseInsensitiveContains(text)
                }
                return room.otherUser.nick.localizedCaseInsensitiveContains(text) || chat.lastChat.localizedCaseInsensitiveContains(text)
            }
        }
    }
}
