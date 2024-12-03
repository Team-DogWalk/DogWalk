//
//  MapView.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    private static let width = UIScreen.main.bounds.width
    private static let height = UIScreen.main.bounds.height
    @StateObject var container: Container<MapIntentProtocol, MapStateProtocol>
    private var state: MapStateProtocol { container.state }
    private var intent: MapIntentProtocol { container.intent }
    @EnvironmentObject var coordinator: MainCoordinator
    @State private var showAnnotation = false
    @State private var isShowingSheet = false
    @State private var showResultPostView = false
    private let network = NetworkManager()
    @EnvironmentObject var appCoordinator: MainCoordinator
}

extension MapView {
    var body: some View {
        ZStack {
            mapView()
            if state.showRefreshButton {
                VStack {
                    refreshButton()
                        .padding()
                    Spacer()
                }
            }
            if state.isTimerOn {
                timerBottomView()
                    .vBottom()
            } else {
                defaultBottomView()
                    .vBottom()
            }
        } //:ZSTACK
        .sheet(isPresented: $isShowingSheet) {
            userInfoBottomSheet(state.selectedAnnotation)
            .presentationDetents([.fraction(0.3)])
        } //바텀시트
        .sheet(isPresented: $showResultPostView) {
            WalkResultView.build(walkTime: state.count, walkDistance: state.locationManager.walkDistance, routeImage: state.routeImage)
            //dogWalkResult(walkTime: <#T##Int#>, walkDistance: <#T##Double#>, routeImage: <#T##UIImage#>)
            //coordinator.push(.dogWalkResult(walkTime: state.count, walkDistance: state.locationManager.walkDistance, routeImage: state.routeImage))
        }
        
    }
}
// MARK: - 지도 관련 부분
private extension MapView {
    func currentLocationButton() -> some View {
        Button {
            print("현위치 버튼 클릭")
            withAnimation {
                guard let coordinate = state.locationManager.locationManager.location?.coordinate else { return }
                intent.updatePosition((MapCameraPosition.region(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.0169, longitudeDelta: 0.0169)))))
            }
            if state.locationManager.locationManager.authorizationStatus == .authorizedAlways || state.locationManager.locationManager.authorizationStatus == .authorizedWhenInUse {
                //showAnnotation = false
            } else {
                intent.showAlert()
            }
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(Color.primaryWhite)
                Image(systemName: "dot.scope")
            }
            .frame(width: 45, height: 45)
        }
        .alert("위치 권한 허용하러 갈멍?", isPresented: Binding(get: {
            state.isAlert
        }, set: { newAlert in
            if !newAlert {
                intent.closeAlert()
            }
        })) {
            Button("이동", role: .destructive) { intent.openAppSettings() }
            Button("취소", role: .cancel) {}
        }
    }
    
    func mapView() -> some View {
        Map(position: Binding(get: {
            state.position
        }, set: { newPosition in
            intent.updatePosition(newPosition)
        })) { //position: 표시할 지도 위치
            UserAnnotation()
            //MARK: 2.좌표 기반 마커 표시
            if showAnnotation {//산책 시작하면 안보이도록
                ForEach(state.posts, id: \.self) { data in
                    setAnnotation(lat: data.geolocation.lat, lng: data.geolocation.lon, post: data)
                }
            }
            if state.locationManager.locations.count > 1 {
                let polylineCoordinates = state.locationManager.locations
                MapPolyline(coordinates: polylineCoordinates)
                    .stroke(state.polylineColor, lineWidth: 5)
            }
        }
        .onAppear {//MARK: 1-1현위치 좌표 전달 완료 
            let center = state.position.region?.center ?? state.locationManager.locationManager.location?.coordinate
            guard let coordinate = center else { return }
            if state.position.followsUserLocation {
                intent.getPostsAtLocation(lat: coordinate.latitude, lon: coordinate.longitude)
            }
            showAnnotation = true
        }//처음엔 annotation 보이도록
        .onMapCameraChange { context in//MARK: 1-2새로고침 시 중심 좌표 전달 완료
            //MARK: **Trouble Shooting** 처음 맵 띄울 때 현 위치와 카메라포지션이 같이 움직여서 해결
            if !state.position.followsUserLocation {
                intent.showRefreshButton()
            }
            //MARK: 산책중 지도 움직였을 때 새로고침버튼 숨김
            if state.isTimerOn {
                intent.hideRefreshButton()
            }
            //MARK: 새로고침 시 통신
            intent.getCenter(context.region)
        }
    }
    //새로고침 버튼
    func refreshButton() -> some View {
        HStack {
            Button {
                print("새로고침 버튼 클릭")
                //MARK: 새로고침 시 통신
                intent.getPostsAtLocation(lat: state.visibleRegion.center.latitude, lon: state.visibleRegion.center.longitude)
                intent.hideRefreshButton()//MARK: 새로고침 버튼 숨기기
                showAnnotation = true
            } label: {
                CommonButton(width: 170, height: 44, cornerradius: 22, backColor: .primaryGreen, text: "이 지역 검색하기", textFont: .pretendardBold14, leftLogo: Image(systemName: "arrow.clockwise"), imageSize: 22)
                    .foregroundStyle(Color.primaryBlack)
            }
        }
    }
    //Annotation
    func setAnnotation(lat: Double, lng: Double, post: PostModel) -> Annotation<Text, some View> {
        Annotation("", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)) {
            customAnnotation()
                .wrapToButton {
                    isShowingSheet.toggle()
                    intent.selectAnnotation(post)
                }
        }
    }
    //커스텀 마커 이미지
    func customAnnotation() -> some View {
        VStack(spacing: 0) {
            Image.asTestLogo
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .font(.headline)
                .foregroundColor(.white)
                .padding(6)
                .background(Color.primaryOrange)
                .cornerRadius(36)
            
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.primaryOrange)
                .frame(width: 15, height: 15)
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -6)
                .padding(.bottom, 40)
        }//:VSTACK
    }
}
// MARK: - 하단 버튼 뷰 부분
private extension MapView {
    //디폴트 프로필 + 산책 시작 버튼
    func defaultBottomView() -> some View {
        VStack {
            currentLocationButton()
                .padding(.horizontal,30)
                .padding(.vertical,5)
                .frame(maxWidth: .infinity, alignment: .trailing)
            HStack {
                CommonProfile(imageURL: "", size: 45)
                
                Spacer()
                    .frame(width: 30)
                
                CommonButton(width: Self.width * 0.65, height: 44, cornerradius: 20, backColor: .primaryLime, text: "산책 시작하기", textFont: .pretendardBold14)
                    .clipShape(RoundedRectangle(cornerRadius: 20)) // 버튼 모양에 맞게 그림자 조정
                    .shadow(color: .black.opacity(0.6), radius: 5, x: 0, y: 5) // 버튼 그림자
                    .wrapToButton {
                        print("산책 시작 버튼 클릭")
                        if state.locationManager.locationManager.authorizationStatus == .authorizedAlways || state.locationManager.locationManager.authorizationStatus == .authorizedWhenInUse {
                            intent.startWalk()
                            intent.startBackgroundTimer()
                            //MARK: 4.마커와 새로고침버튼 안보이도록
                            intent.hideRefreshButton()
                            showAnnotation = false
                        } else {
                            intent.showAlert()
                        }
                    }
                    .alert("위치 권한 허용하러 갈멍?", isPresented: Binding(get: {
                        state.isAlert
                    }, set: { newAlert in
                        if !newAlert {
                            intent.closeAlert()
                        }
                    })) {
                        Button("이동", role: .destructive) { intent.openAppSettings() }
                        Button("취소", role: .cancel) {}
                    }
            } //:HSTACK

        }
        .padding(.bottom)
    }
    //타이머 시작 시 바텀 뷰
    func timerBottomView() -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color.primaryGreen)
                .overlay {
                    let hours = state.count / 3600
                    let minutes = String(format: "%02d", (state.count % 3600) / 60)
                    let seconds = String(format: "%02d", state.count % 3600 % 60)
                    Text("\(hours):\(minutes):\(seconds)") // 시간 넣기
                        .font(.pretendardBold16)
                        .foregroundStyle(.white)
                }
            Rectangle()
                .fill(Color.primaryLime)
                .overlay {
                    ZStack {
                        Rectangle()
                            .fill(Color.clear)
                            .wrapToButton {
                                print("산책 종료 버튼 클릭")
                                await intent.setRouteImage(route: state.locationManager.locations)
                                intent.stopWalk()
                                intent.stopBackgroundTimer()
                                // TODO: coordinator 설정 해주기
                                //coordinator.push(.dogWalkResult(walkTime: state.count, walkDistance: state.locationManager.walkDistance, routeImage: state.routeImage))
                                //coordinator.sheet(.dogWalkResult(walkTime: state.count, walkDistance: state.locationManager.walkDistance, routeImage: state.routeImage))
                                //coordinator.presentSheet(.dogWalkResult(walkTime: state.count, walkDistance: state.locationManager.walkDistance, routeImage: state.routeImage))
                                //coordinator.presentFullScreenCover(.dogWalkResult(walkTime: state.count, walkDistance: state.locationManager.walkDistance, routeImage: state.routeImage))
                                //MARK: 4.마커는 다시 보이도록
                                showResultPostView.toggle()
                                showAnnotation = true
                            }
                        Text("산책 종료")
                            .font(.pretendardBold16)
                    } //:ZSTACK
                }
        } //:HSTACK
        .frame(height: Self.height * 0.07)
    }
    //지도 마커 클릭 시 바텀 시트
    func userInfoBottomSheet(_ post: PostModel) -> some View {
        VStack {
            HStack {
                CommonProfile(imageURL: post.creator.profileImage, size: 65)
                    .padding(.leading)
                //게시글 유저 데이터
                userInfoTextField("\(post.creator.nick)", "", mainFont: .pretendardBold16, subFont: .pretendardRegular13)
            } //:HSTACK
            .hLeading()
            
            Spacer()
                .frame(height: 15)
            //게시글 내용
            userInfoTextField(post.title, post.content, 3, mainFont: .pretendardBold14, subFont: .pretendardRegular12)
                .padding(.horizontal)
                .hLeading()
            
            HStack(alignment: .center, spacing: 15) {
                CommonButton(width: Self.width * 0.55, height: 44, cornerradius: 20, backColor: .primaryLime, text: "작성한 게시물 보기", textFont: .pretendardBold14)
                    .wrapToButton {
                        isShowingSheet = false
                        coordinator.push(.communityDetail(postID: post.postID))
                    }
                
                CommonButton(width: Self.width * 0.25, height: 44, cornerradius: 20, backColor: .primaryWhite, text: "멍톡 보내기", textFont: .pretendardBold14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.primaryGreen, lineWidth: 1) // 보더 색상과 두께 설정
                    )
                    .wrapToButton {
                        // TODO: 해당 게시글의 id (마커 클릭했을때)
                        // TODO: 나중에 채팅에 넣어주기
                        Task {
                            do {
                                let body = NewChatRoomBody(opponent_id: post.creator.userID)
                                let response = try await network.requestDTO(
                                    target: .chat(.newChatRoom(body: body)),
                                    of: ChattingRoomDTO.self
                                    
                                )
                                let _ = print(response, "dadasdasd")
                                ChatRepository.shared.createChatRoom(chatRoomData: response.toDomain())
                                isShowingSheet = false
                                
                                let otherNick = response.participants.filter { $0.user_id != UserManager.shared.userID }.first?.nick ?? "상대방"
                                appCoordinator.push(.chattingRoom(roomID: response.room_id, nick: otherNick))
                            } catch {
                                print("Community DetailView: \(error)")
                            }
                        }
                        
                    }
            } //:HSTACK
        } //:VSTACK
        .padding([.top])
        .vTop()
        .hLeading()
    }    //바텀 시트 메인, 서브 텍스트 필드
    func userInfoTextField(_ mainText: String, _ subText: String, _ subTextLimit: Int = 1, mainFont: Font, subFont: Font) -> some View {
        VStack(alignment: .leading) {
            Text(mainText)
                .font(mainFont)
                .lineLimit(1)
            Spacer()
                .frame(height: 5)
            Text(subText)
                .font(subFont)
                .foregroundStyle(Color.gray) // 나중에 색 변경해주기
                .lineLimit(subTextLimit)
        } //:VSTACK
    }
}

extension MapView {
    static func build() -> some View {
        let state = MapState()
        let intent = MapIntent(state: state)
        let container = Container(
            intent: intent as MapIntentProtocol,
            state: state as MapStateProtocol,
            modelChangePublisher: state.objectWillChange
        )
        let view = MapView(container: container)
        return view
    }
}
