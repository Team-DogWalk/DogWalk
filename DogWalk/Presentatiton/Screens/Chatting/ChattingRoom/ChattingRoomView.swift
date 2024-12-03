//
//  ChattingRoomView.swift
//  DogWalk
//
//  Created by 박성민 on 10/31/24.
//

import SwiftUI

struct ChattingRoomView: View {
    private static let width = UIScreen.main.bounds.width
    private static var height = UIScreen.main.bounds.height
    
    @StateObject var container: Container<ChattingRoomIntentProtocol, ChattingRoomStateProtocol>
    private var state: ChattingRoomStateProtocol { container.state }
    private var intent: ChattingRoomIntentProtocol { container.intent }
    
    @EnvironmentObject var coordinator: MainCoordinator
    @EnvironmentObject var appDelegate: AppDelegate
    
    @State private var bottomPadding: CGFloat = 0.0
    @State private var showKeyboard = false
    
    @Environment(\.scenePhase) private var scenePhase
}

extension ChattingRoomView {
    static func build(roomID: String, nick: String) -> some View {
        let state = ChattingRoomState(roomID: roomID, nick: nick)
        let useCase = DefaultChattingRoomUseCase(roomID: roomID)
        let intent = ChattingRoomIntent(state: state, useCase: useCase)
        let container = Container(intent: intent as ChattingRoomIntentProtocol,
                                  state: state as ChattingRoomStateProtocol,
                                  modelChangePublisher: state.objectWillChange)
        let view = ChattingRoomView(container: container)
        return view
    }
}

extension ChattingRoomView {
    var body: some View {
        VStack {
            GeometryReader {
                //채팅부분
                ChatView(size: $0.size)
                // TODO: 키보드가 없어질때 자연스러운 조절을 위해 CommonSendView에 해당 이벤트 전달해주기
                // 키보드
                CommonSendView(
                    proxy: $0,
                    yOffset: $bottomPadding,
                    showKeyboard: $showKeyboard
                ) { text in // 이미지 보낼 경우 (UIImage)
                    print(text)
                    Task {
                        await intent.sendTextMessage(roomID: state.roomID, text: text)
                    }
                } completionSendImage: { image in // 이미지 보낼 경우 (UIImage)
                    print(image)
                    Task {
                        await intent.sendImageMessage(roomID: state.roomID, image: image)
                    }
                }
            }
        }  //:VSTACK
        .ignoresSafeArea()
        .background(Color.primaryWhite)
        .padding(.top, 1.0)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(state.nick)
        .tabBarHidden(true)
        .task {
            intent.onAppearTrigger(roomID: state.roomID)
        }
        .onDisappear {
            intent.onDisappearTrigger()
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            print("oldValue", oldValue)
            print("newValue", newValue)
            switch newValue {
            case .active: // Socket 다시 열어주기
                intent.onActiveTrigger(roomID: state.roomID)
                // coordinator.pop()
            case .background: // Socket 닫아주기
                // intent.onDisappearTrigger()
                // intent.onBackgroundTrigger()
                scheduleDisconnectTask(after: 60)
            default:
                return
            }
        }
    }
    
    private func scrollToLastMessage(scroll: ScrollViewProxy) {
        if let lastMessage = state.chattingData.last {
            scroll.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
    
    private func scheduleDisconnectTask(after interval: TimeInterval) {
        appDelegate.scheduleSocketDisconnectTask(after: interval)
    }
}

// MARK: - 채팅 내역 부분
private extension ChattingRoomView {
    @ViewBuilder
    func ChatView(size: CGSize) -> some View {
        ScrollViewReader { scroll in
            ScrollView {
                LazyVStack(spacing: 2.0) {
                    ForEach(state.chattingData) { model in
//                        let _ = print("State에서 확인", model)
                        chattingView(size: size, model: model)
                            .padding(.bottom, 10)
                            .onTapGesture {
                                self.dismissKeyboard()
                                showKeyboard = false
                            }
                    }
                } //:VSTACK
                .onChange(of: showKeyboard) { oldValue, newValue in // 키보드 감지
                    guard newValue else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation { scrollToLastMessage(scroll: scroll) } // 키보드 상태가 바뀌면 스크롤 위치 변경
                    }
                    
                }
                .onChange(of: state.chattingData) { oldValue, newValue in // 새로운 메시지 감지
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation { scrollToLastMessage(scroll: scroll) } // 새로운 데이터가 들어올 경우 스크롤 위치 변경
                    }
                }
            } //:SCROLL
            .scrollIndicators(.hidden) //스크롤 Indicators 숨김
            .padding(.trailing) //자신도 프로필이 있을경유 horizontal으로 변경해주기
            .padding(.leading, 5)
            .padding(.bottom, bottomPadding)
        }
    }
}

// MARK: - 전체 채팅 뷰
private extension ChattingRoomView {
    @ViewBuilder
    func chattingView(size: CGSize, model: ChattingModel) -> some View {
//        let _ = print("modelType", model.type)
//        let _ = print("files", model.files)  // 파일 배열 확인용 로그
        let xOffSet = size.width / 2
        
        // files 배열로 실제 타입 판단
        if !model.files.isEmpty {  // 파일이 있으면 이미지 메시지
            ZStack {
                if model.sender.userID != UserManager.shared.userID {
                    userProfileView(data: model)
                        .offset(x: -xOffSet + 30)
                }
                imageMessageView(size: size, model: model)
            }
        } else {  // 파일이 없으면 텍스트 메시지
            ZStack {
                if model.sender.userID != UserManager.shared.userID {
                    userProfileView(data: model)
                        .offset(x: -xOffSet + 30)
                }
                messageView(size: size, model: model)
            }
        }
    }
}

// MARK: - 말풍선 부분
private extension ChattingRoomView {
    @ViewBuilder
    func messageView(size: CGSize, model: ChattingModel) -> some View {
        let isRight = model.sender.userID == UserManager.shared.userID
        
        //말풍선 size 지정
        let minBubbleHeight: CGFloat = 18.0
        let minBubbleWidth: CGFloat = 15.0
        let maxBubbleWidth: CGFloat = Self.width * 0.62
        
        //mesRect -> 텍스트 너비가 작으면 가장 작은 너비, 텍스트가 길변 큰 폭을 차지하도록 구현
        let mesRect = model.content.estimatedTextRect(width: maxBubbleWidth)
        let mesWidth = mesRect.width <= minBubbleWidth ?
        minBubbleWidth :
        (mesRect.width >= maxBubbleWidth) ? maxBubbleWidth : mesRect.width
        let mesHeight = mesRect.height <= minBubbleHeight ? minBubbleHeight : mesRect.height
        
        let bubbleHeight = mesHeight + 15
        let bubbleWidth = mesWidth + 20
        let xOffSet = (size.width - bubbleWidth) / 2 - 20.0 // 말풍선 offSet 설정
        
        HStack {
            if model.sender.userID == UserManager.shared.userID { //상대 프로필
                chatDateView(model.createdAt)
                    .offset(x: xOffSet - 15, y: 4)
            }
            //말풍선 부분
            Rectangle()
                .fill(.clear)
            //isRight ? Color.red : Color.blue) //말풍선 색 변경해주기
                .frame(width: bubbleWidth, height: bubbleHeight)
                .background(
                    //말풍선 이미지로 이쁘게 해서 구현해도 될듯~
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isRight ? Color.primaryOrange.opacity(0.8) : Color.primaryGray.opacity(0.6))
                        .frame(width: bubbleWidth - 5, height: bubbleHeight)
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(x: isRight ? 1.0 : -1.0) // 이미지 뒤집기~
                        .offset(x: isRight ? xOffSet - 25 : -xOffSet + 65) //여기고침
                    
                )
                .overlay(alignment: isRight ? .trailing : .leading) {
                    HStack {
                        Text(model.content)
                            .font(.pretendardRegular16)
                            .frame(width: mesWidth, height: mesHeight)
                            .padding(isRight ? .trailing : .leading, isRight ? 5 : 15)
                            .offset(x: isRight ? xOffSet - 30 : -xOffSet + 60)
                    }
                    //.foregroundStyle(isRight ? ) // 채팅 색 변경
                }
            
            if model.sender.userID != UserManager.shared.userID { //상대방 날짜 부분
                chatDateView(model.createdAt)
                    .offset(x: -xOffSet + 55, y: 4)
            }
        } //:HSTACK
        .id(model.id) //각 cell 아이디 부여
    }
}

// MARK: - 채팅이 이미지일 경우
private extension ChattingRoomView {
    @ViewBuilder
    func imageMessageView(size: CGSize, model: ChattingModel) -> some View {
        let isRight = model.sender.userID == UserManager.shared.userID
        let width = size.width
//        let _ = print("ChattingRoomView~~~~", model.files.first ?? "없ㅇ어")
        HStack {
            if isRight {
                chatDateView(model.createdAt)
                    .offset(x: width * 0.1985)
                    .padding(.bottom, 5)
            }
            // 이미지 말풍선 부분
            let _ = print(model.files.first)
            asImageView(url: model.files.first ?? "", saveType: .document)
                .frame(width: 150, height: 150) // 이미지 크기 조정
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isRight ? Color.primaryOrange.opacity(0.8) : Color.primaryGray.opacity(0.6))
                        .frame(width: 150, height: 150)
                        .scaleEffect(x: isRight ? 1.0 : -1.0) // 이미지 말풍선 방향
                )
                .offset(x: isRight ? width / 2 - 120 : -width / 2 + 160)
                .padding(isRight ? .trailing : .leading, 15)
                .padding(.bottom, 10)
            
            if !isRight { // 상대방 날짜
                chatDateView(model.createdAt)
                    .offset(x: -width * 0.105)
                    .padding(.bottom, 5)
            }
        }
        .id(model.id) // 각 셀에 고유 아이디 부여
    }
}

// MARK: - 사용자 프로필 부분
private extension ChattingRoomView {
    @ViewBuilder
    func userProfileView(data: ChattingModel ) -> some View {
        CommonProfile(imageURL: data.sender.profileImage, size: 33)
            .vTop()
    }
}

// MARK: - 채팅 날짜 부분
private extension ChattingRoomView {
    @ViewBuilder
    func chatDateView(_ date: String) -> some View {
        Text(date.getFormattedDateString(.time))
            .font(.pretendardLight12)
            .frame(width: 60, height: 25)
            .vBottom()
    }
}
