//
//  ChattingView.swift
//  DogWalk
//
//  Created by 김윤우 on 10/29/24.
//

import SwiftUI
import Combine

struct ChattingListView: View {
    @EnvironmentObject var coordinator: MainCoordinator
    @State private var searchText = ""
    @StateObject var container: Container<ChattingListIntentProtocol, ChattingListStateProtocol>
    private var state: ChattingListStateProtocol { container.state }
    private var intent: ChattingListIntentProtocol { container.intent }
}

extension ChattingListView {
    static func build() -> some View {
        let state = ChattingListState()
        let useCase = DefaultChattingListUseCase()
        let intent = ChattingListIntent(state: state, useCase: useCase)
        let container = Container(
            intent: intent as ChattingListIntentProtocol,
            state: state as ChattingListStateProtocol,
            modelChangePublisher: state.objectWillChange
        )
        let view = ChattingListView(container: container)
        return view
    }
}

extension ChattingListView {
    var body: some View {
        NavigationView {
            ScrollView {
                chattingListView()
            }
            .searchable(text: Binding(get: {
                state.searchText //입력한 텍스트
            }, set: { newText in
                intent.inputSearchText(newText) //입력값 전달
            }), prompt: "검색") // SearchBar
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CommonTitleView(title: "MeongTalk")  // 좌상단 앱 로고
                }
            }
            .toolbar(.visible, for: .tabBar)
        }
        .onAppear {
            Task { await intent.onAppearTrigger() }
        }
    }
    
    // 채팅방 목록
    private func chattingListView() -> some View {
        ForEach(state.chattingRoomList, id: \.roomID) { item in
            chattingViewCell(item)
        }
    }
    
    // 채팅방 Cell
    private func chattingViewCell(_ item: ChattingRoomModel) -> some View {
        Button {
            coordinator.push(.chattingRoom(roomID: item.roomID, nick: item.otherUser.nick))
        } label: {
            HStack {
                CommonProfile(imageURL: item.otherUser.profileImage, size: 60)
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.otherUser.nick) // 이름
                        .font(.pretendardBold18)
                        .foregroundColor(.primaryBlack)
                    Text(item.lastChat?.type == .image ? "사진" : item.lastChat?.lastChat ?? "")
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .font(.pretendardRegular12)
                    
                        .foregroundColor(.gray)
                }
                Spacer()
                
                Text(item.updatedAt.getFormattedDateStringWithToday())
                    .font(.pretendardRegular14)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }
}
