//
//  CommunityView.swift
//  DogWalk
//
//  Created by junehee on 10/30/24.
//

import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var appCoordinator: MainCoordinator
    @StateObject var container: Container<CommunityIntentProtocol, CommunityStateProtocol>
    private var intent: CommunityIntentProtocol { container.intent }
    private var state: CommunityStateProtocol { container.state }
    static private let width = UIScreen.main.bounds.width
    static private let height = UIScreen.main.bounds.height
    @State private var isShowingSheet = false
}
extension CommunityView {
    static func build() -> some View {
        let state = CommunityState()
        /*
         useCase를 뷰에서 실체화 시킴
         */
        let intent = CommunityIntent(state: state, useCase: DefaultCommunityUseCase(checkPostType: state.area, category: state.selectCategory))
        
        let container = Container(
            intent: intent as CommunityIntentProtocol,
            state: state as CommunityStateProtocol,
            modelChangePublisher: state.objectWillChange
        )
        let view = CommunityView(container: container)
        return view
    }
}
extension CommunityView {
    var body: some View {
        NavigationView {
            ZStack {
                if state.contentState == .loading {
                    CommonLoadingView()
                }
                if state.contentState == .error {
                    CommonErrorView()
                }
                contentView()
            }
//            switch state.contentState {
//            case .loading:
//                CommonLoadingView()
//                //loadingView()
//            case .content:
//                contentView()
//                //UIActivityIndicatorView()
//            case .error:
//                CommonErrorView()
//            }
        } //:NAVIGATION
        .onAppear {
            if state.contentState != .content {
                intent.onAppear()
            }
        }
    }
}
private extension CommunityView {
    //실제 화면
    func contentView() -> some View {
        ZStack {
            ScrollView {
                filterView()
                ForEach(state.postList, id: \.postID) { item in
                    postViewCell(item) //ListCellView
                        .onTapGesture {
                            print(item.postID)
                            print("-----")
                            //673807612cced30805615894
                            appCoordinator.push(.communityDetail(postID: item.postID))
                        }
                        
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    areaSelectionView() // 좌상단 위치선택(ex.문래동)
                }
            }
            floatingButton()
        }
        .sheet(isPresented: $isShowingSheet) {
            bottomSheetView() // 문래동 버튼 탭시 올라오는 바텀시트
                .presentationDragIndicator(.visible)
                .presentationDetents([.fraction(0.3)])
        }
        
    } //:NAVIGATION
}

// 좌상단 버튼 뷰
private extension CommunityView {
    private func filterView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(state.categorys, id: \.self) { item in
                    filterButtonsView(item)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    private func filterButtonsView(_ button: CommunityCategoryType) -> some View {
        CommonButton(width: Self.width * 0.22,
                     height: Self.height * 0.04,
                     cornerradius: 12,
                     backColor: state.selectCategory == button ? .primaryOrange : .primaryLime,
                     text: button.rawValue,
                     textFont: .pretendardBlack15)
        
        .background {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primaryBlack, lineWidth: 1)
        }
        .wrapToButton {
            // 우리동네 10km 이내 게시물 필터
            intent.selectCategory(category: button)
        }
    }
    
    // 좌상단 거리별 리스트 변경 버튼
    private func areaSelectionView() -> some View {
        HStack {
            Button {
                isShowingSheet.toggle()
            } label: {
                Group {
                    Text(state.area.title)
                        .font(.bagelfat28)
                    Image.asDownChevron
                }
                .foregroundColor(.primaryBlack)
            }
            Spacer()
        }
    }
    
    
    
    // Floating Button
    private func floatingButton() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    appCoordinator.push(.communityCreate)
                }label: {
                    Image.asPencil
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color.primaryGreen)
                        )
                }
                .padding(.bottom)
                .padding(.trailing)
            }
        }
    }
}
// PostCell
private extension CommunityView {
    func postViewCell(_ item: PostModel) -> some View {
        HStack {
            asImageView(url: item.files.first ?? "", image: .asTestImage)
                .scaledToFill()
                .frame(width: Self.width * 0.25, height: Self.width * 0.25)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.title) // 제목
                        .font(.pretendardBold16)
                    Spacer()
                    Text(item.created.getFormattedDateString(.dot)) // 게시된 시간
                        .font(.pretendardRegular12)
                        .foregroundStyle(.gray)
                }
                
                Text(item.content) // 본문
                    .font(.pretendardRegular14)
                    .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                    .multilineTextAlignment(.leading)
                Spacer()
                HStack {
                    categoryLabel(text: item.category.rawValue)
                    Spacer()
                    Button {
                        // 댓글 동작 구현
                    } label: {
                        HStack(spacing: 4) {
                            Image.asMessage  // 댓글
                                .foregroundColor(.primaryBlack)
                            Text("\(item.comments.count)") // 댓글 수
                                .font(.pretendardRegular14)
                                .foregroundColor(.gray)
                        }
                        Button {
                            // 좋아요 동작 구현
                        } label: {
                            HStack(spacing: 4) {
                                Image.asHeart
                                    .foregroundColor(.primaryBlack)
                                Text("\(item.likes.count)") // 좋아요 수
                                    .font(.pretendardRegular14)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .padding(.leading, 4)
            Spacer()
        }
    }
    // 카테고리 라벨
    func categoryLabel(text: String) -> some View {
        Text(text)
            .font(.pretendardRegular12)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.red.opacity(0.5))
            )
    }
}
// 문래동 버튼 눌렀을 때 올라오는 bottomSheetView
private extension CommunityView {
    func bottomSheetView() -> some View {
        VStack(spacing: 20) {
            Text("동네 범위 설정")
                .padding(.leading)
                .font(.pretendardBold20)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 전체 게시물 필터 버튼
            CommonButton(width: Self.width * 0.9,
                         height: Self.height * 0.05,
                         cornerradius: 8,
                         backColor: .clear,
                         text: "우리동네(반경 10KM)",
                         textFont: .pretendardRegular19,
                         textColor: .gray)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primaryBlack, lineWidth: 1)
            }
            .wrapToButton {
                // 우리동네 10km 이내 게시물 필터
                isShowingSheet.toggle()
                intent.changeArea(area: .userLocation)
            }
            
            // 전체 게시물 버튼
            CommonButton(width: Self.width * 0.9,
                         height: Self.height * 0.05,
                         cornerradius: 8,
                         backColor: .primaryOrange.opacity(0.8),
                         text: "모든 동네(전국)",
                         textFont: .pretendardRegular19,
                         textColor: .white)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primaryBlack, lineWidth: 1)
            }
            .wrapToButton {
                isShowingSheet.toggle()
                intent.changeArea(area: .all)
            }
            Spacer()
        }
        .padding(.top, 16)
    }
}
#Preview {
    CommunityView.build()
}
