//
//  HomeView.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    @StateObject var container: Container<HomeIntentProtocol, HomeStateProtocol>
    private var state: HomeStateProtocol { container.state }
    private var intent: HomeIntentProtocol { container.intent }
    @EnvironmentObject var coordinator: MainCoordinator
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                topCharactorView()
                middleButtonSView()
                adBannerView()
                popularityDogWalkPostView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("도그워크")
                        .font(.bagelfat28)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    CommonProfile(imageURL: state.myProfile.profileImage, size: 44)
                        .wrapToButton {
                            intent.profileButtonTap()
                            
                        }
                }
            }
        }
        .onChange(of: state.profileButtonState) { oldValue, newValue in
            if newValue {
                coordinator.push(.setting)
                intent.resetProfileButtonSate()
            }
        }
        .onAppear {
            UserManager.shared.isUser = false
            ChatRepository.shared.deleteAllChatRooms()
        }
        .task {
            await intent.fetchPostList()
            await intent.fetchWeatherData()
            await intent.fetchProfile()
        }
    }
}

extension HomeView {
    
    //MARK: 상단 날씨, 멘트, 캐릭터 뷰
    func topCharactorView() -> some View {
        ZStack {
            Color.init(hex: "BFD4EF")
                .frame(maxWidth: .infinity, maxHeight: height/2.4)
            
            Image("almostClear")
                .resizable()
                .frame(width: 240, height: 240)
                .frame(maxWidth: .infinity, maxHeight: height/2, alignment: .bottomTrailing)
                .padding(.trailing)
            
            VStack {
                VStack(alignment: .leading) {
                    Text("산책 가방 어디써? 빨리 나가자")//prompt
                        .font(.pretendardSemiBold30)
                        .padding(.vertical,1)
                    VStack(alignment: .leading) {
                        Text("위치 · \(state.weatherData.userAddress)")//위치
                            .padding(.vertical,1)
                        Text("날씨 · \(state.weatherData.weather)")//날씨
                    }
                    .font(.pretendardRegular17)
                    .foregroundColor(.gray)
                }
                .padding(20)
                .frame(maxWidth: width*2/3, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: height/2, alignment: .topLeading)
            
        }
        .frame(height: height/2.4)
    }
    
    //MARK: 함께 산책하기, 산책 인증하기 뷰
    func middleButtonSView() -> some View {
        HStack(spacing: 20) {
            CommonButton(width: 170, height: 50, cornerradius: 20, backColor: .primaryGreen, text: "함께 산책하기  🐾", textFont: .pretendardSemiBold18)
                .wrapToButton {
                    coordinator.changeTab(tab: .dogWalk)
                }
            CommonButton(width: 170, height: 50, cornerradius: 20, backColor: .primaryLime, text: "산책 인증하기", textFont: .pretendardSemiBold18, rightLogo: .asTestLogo, imageSize: 20)
                .wrapToButton {
                    coordinator.changeTab(tab: .community)
                }
        }
        .padding(.vertical,10)
    }
    
    //MARK: 중간 광고 배너뷰
    func adBannerView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(1..<10, id: \.self) {_ in
                    Image(.testAdCell)//광고 이미지
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .containerRelativeFrame(.horizontal)//컨테이너에 상대적인 크기를 지정
                }
            }
        }
        .scrollTargetBehavior(.paging)
    }
    
    //MARK: 하단 인기 산책 뷰
    func popularityDogWalkPostView() -> some View {
        VStack {
            Text("인기 산책 인증")
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .font(.pretendardBold15)
                .padding(.horizontal,20)
                .padding(.vertical,5)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(state.popularityDogWalkList, id: \.postID) { data in
                        asImageView(url: "/" + (data.files.first ?? ""))
                            .frame(width: 100, height: 130)
                            .clipShape(.rect(cornerRadius: 15))
                            .wrapToButton {
                                //MARK: Communitiy DetailView로 이동
                                DispatchQueue.main.async {
                                    coordinator.push(.communityDetail(postID: data.postID))
                                    print(data.postID)
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

extension HomeView {
    static func build() -> some View {
        let state = HomeState()
        let useCase = HomeViewUseCase()
        let intent = HomeIntent(state: state, useCase: useCase)
        let container = Container(
            intent: intent as HomeIntentProtocol,
            state: state as HomeStateProtocol,
            modelChangePublisher: state.objectWillChange
        )
        let view = HomeView(container: container)
        return view
    }
}
