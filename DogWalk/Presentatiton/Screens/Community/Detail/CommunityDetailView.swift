//
//  CommunityDetailView.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import SwiftUI

struct CommunityDetailView: View {
    @StateObject var container: Container<CommunityDetailIntentProtocol, CommunityDetailStateProtocol>
    private var intent: CommunityDetailIntentProtocol  { container.intent }
    private var state: CommunityDetailStateProtocol { container.state }
    @EnvironmentObject var appCoordinator: MainCoordinator
    @State private var bottomPadding: CGFloat = 0.0
    @State private var showKeyboard = false
    private let network = NetworkManager()
    private static let width = UIScreen.main.bounds.width
    private static let height = UIScreen.main.bounds.height
    var postID: String //하위뷰에서 포스트 id 받아오기
}
// MARK: - 빌드 부분
extension CommunityDetailView {
    static func build(postID: String) -> some View {
        let state = CommunityDetailState()
        let intent = CommunityDetailIntent(state: state, useCase: DefaultCommunityDetailUseCase(id: postID))
        
        let container = Container(
            intent: intent as CommunityDetailIntentProtocol,
            state: state as CommunityDetailStateProtocol,
            modelChangePublisher: state.objectWillChange
        )
        let view = CommunityDetailView(container: container, postID: postID)
        return view
    }
}
// MARK: - 메인 뷰
extension CommunityDetailView {
    @ViewBuilder
    var body: some View {
        VStack {
            switch state.contentState {
            case .loading:
                CommonLoadingView()
                //loadingView()
            case .content:
                contentView()
            case .error:
                CommonErrorView()
            }
        }.onAppear {
            intent.onAppear()
        }
    }
    
    //실제 뷰
    func contentView() -> some View {
        VStack {
            GeometryReader {
                ScrollView(.vertical) {
                    VStack(spacing: 12) {
                        communityContentView()
                        commentListView()
                    }
                    .background(Color.primaryGray.opacity(0.6))
                }
                .scrollIndicators(.hidden)
                .padding(.bottom, 100)
                .onTapGesture {
                    self.dismissKeyboard()
                    showKeyboard = false
                }
            
                CommonSendView(
                    proxy: $0,
                    yOffset: $bottomPadding,
                    showKeyboard: $showKeyboard,
                    showImageSelectButton: false) { text in
                        intent.sendContent(text: text) // 댓글 입력시
                    } completionSendImage: { _ in }

            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .navigationTitle("산책 인증")  // 상위뷰에서 카테고리명 데이터 필요
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    intent.toggleisLike(isLike: state.isLike)
                } label: {
                    if state.isLike {
                        Image.asHeartFill
                            .foregroundStyle(Color.primaryOrange)
                    } else {
                        Image.asHeart
                            .foregroundStyle(Color.primaryOrange)
                    }
                }

                Button {
                    // TODO: 이거 채팅방에서 진행해주기
                    Task {
                        do {
                            let body = NewChatRoomBody(opponent_id: state.post.creator.userID)
                            let response = try await network.requestDTO(
                                target: .chat(.newChatRoom(body: body)),
                                of: ChattingRoomDTO.self
                                
                            )
                            let _ = print(response, "dadasdasd")
                            ChatRepository.shared.createChatRoom(chatRoomData: response.toDomain())
                            let nick = response.participants.filter { $0.user_id != UserManager.shared.userID }.first?.nick ?? "상대방"
                            appCoordinator.push(.chattingRoom(roomID: response.room_id, nick: nick))
                        } catch {
                            print("Community DetailView: \(error)")
                        }
                    }
                } label: {
                    Image.asMessage
                }
            }
        }
    }
}

// MARK: - 컨텐츠 부분
private extension CommunityDetailView {
    // 카테고리 라벨
    func categoryLabel(text: String) -> some View {
        Text(text)
            .font(.pretendardBold14)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.red.opacity(0.5))
                    .frame(height: 30)
            )
            
    }
    // 게시물 콘텐츠 뷰
    func communityContentView() -> some View {
        VStack {
            HStack {
                categoryLabel(text: state.post.category.rawValue)
                if state.post.views >= 3 {
                CommonButton(width: 100, height: 30, cornerradius: 5, backColor: .primaryOrange, text: "인기글", textFont: .pretendardBold14,textColor: .primaryWhite, leftLogo: Image(systemName: "flame.fill"), imageSize: 17)
                    .foregroundStyle(Color.red)
                }
            }
            .hLeading()
            // 프로필 + 닉네임 + 게시물 작성일
            HStack {
                CommonProfile(imageURL: state.post.creator.profileImage, size: 40)
                Text(state.post.creator.nick)
                    .font(.pretendardBold16)
                Spacer()
                Text(state.post.created)
                    .font(.pretendardRegular12)
                    .foregroundStyle(Color.primaryBlack.opacity(0.5))
            }
            .frame(minHeight: 30)
            //.padding(.bottom, 10)
            
            // 게시물 제목
            Text(state.post.title)
                .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                .multilineTextAlignment(.leading)
                .font(Font.pretendardBold18)
            // 게시물 내용
            Text(state.post.content)
                .font(.pretendardRegular14)
                .lineSpacing(4)
                .hLeading()
            
            asImageView(url: state.post.files.first ?? "", image: .asTestImage)
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
                .padding(.top, 10)
            
            // 댓글 이모지 + 카운트
            HStack(spacing: 5) {
                Image.asMessage
                Text(state.post.comments.count.formatted())
                    .font(.pretendardSemiBold16)
                Text("조회 \(state.post.views.formatted())")
                    .font(.pretendardSemiBold14)
            }
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
        }
        .padding(.horizontal)
        .background(Color.primaryWhite)
    }
}
// MARK: - 댓글 부분
private extension CommunityDetailView {
    // 댓글 목록 뷰
    func commentListView() -> some View {
        LazyVStack(spacing: 20) {
            ForEach(state.post.comments, id: \.commentID) { item in
                commentCell(comment: item)
            }
        }
        .padding([.top, .horizontal, .bottom])
        .background(Color.primaryWhite)
    }
    
    // 댓글 셀
    func commentCell(comment: CommentModel) -> some View {
        // 프로필 이미지 + 닉네임 + 댓글
        HStack(alignment: .top, spacing: 5) {
            //asImageView(url: comment.creator.profileImage, image: .asTestProfile)
            CommonProfile(imageURL: comment.creator.profileImage, size: 33)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(comment.creator.nick)
                    .font(.pretendardBold16)
                Text(comment.content)
                    .font(.pretendardRegular14)
                    .lineSpacing(2)
            }
            .padding(.leading)
            Spacer()
        }
    }
}

#Preview {
    CommunityDetailView.build(postID: "673807612cced30805615894")
}
