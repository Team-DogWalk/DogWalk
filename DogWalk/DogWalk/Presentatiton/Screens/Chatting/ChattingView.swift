    //
//  ChattingView.swift
//  DogWalk
//
//  Created by 김윤우 on 10/29/24.
//

import SwiftUI

struct TestData: Identifiable, Hashable {
    let id: UUID = UUID()
    var name: String
    var chat: String
    var lastChatTime: String
    
    init(name: String = "멋쟁이 윤우", chat: String = "제일 좋아하는 건~~~~ 유킷, 스유, mvvm, mvi, tca, 렛츠고", lastChatTime: String = "20:53") {
        self.name = name
        self.chat = chat
        self.lastChatTime = lastChatTime
    }
}

struct ChattingView: View {
    @EnvironmentObject var coordinator: MainCoordinator
    @State private var searchText = ""
    @State private var items = (0..<10).map { _ in TestData() } // 테스트 데이터 배열, 실제 데이터로 변경
    var body: some View {
        NavigationStack {
            ScrollView {
                chattingListView()
            }
            .searchable(text: $searchText, prompt: "검색") // SearchBar
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    appLogo() // 좌상단 앱 로고
                }
            }
            .toolbar(.visible, for: .tabBar)
        }
    }
    
    private func chattingListView() -> some View {
        ForEach(items, id: \.id) { item in
            chattingViewCell(item)
        }
    }
    
    // 채팅방 Cell
    private func chattingViewCell(_ item: TestData) -> some View {
        //MARK: coordinator 적용 후 버튼으로 변경
        Button {
            coordinator.push(.chattingRoom)
        } label: {
            HStack {
                CommonProfile(image: .asTestImage, size: 60)
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name) // 이름
                        .font(.pretendardBold18)
                        .foregroundColor(.primaryBlack)
                    Text(item.chat) // 내용
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .font(.pretendardRegular12)
                    
                        .foregroundColor(.gray)
                }
                Spacer()
                
                Text(item.lastChatTime)
                    .font(.pretendardRegular14)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
    }
    
    // 좌상단 앱 로고
    private func appLogo() -> some View {
        HStack {
            Text("MeongTalk")
                .font(.bagelfat28)
            Spacer()
        }
    }
}
#Preview {
    ChattingView()
}
