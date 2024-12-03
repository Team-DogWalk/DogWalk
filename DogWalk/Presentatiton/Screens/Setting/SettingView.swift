//
//  SettingView.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import SwiftUI
import MapKit
//struct MyProfileDTO: Decodable {
//    let user_id: String
//    // let email: String
//    let nick: String
//    let profileImage: String?
//    // let phoneNum: String
//    // let gender: String
//    // let birthDay: String
//    let info1: String                   // 주소
//    let info2: String                   // 위도
//    let info3: String                   // 경도
//    let info4: String                   // 포인트
//    let info5: String                   // 온도
//    // let followers: [FollowDTO]
//    // let following: [FollowDTO]
//    // let posts: [String]
//}
struct SettingView: View {
    @EnvironmentObject var coordinator: MainCoordinator
    @State private var nick = UserManager.shared.userNick
    @State private var location = UserManager.shared.roadAddress
    @State private var lon = ""
    @State private var lat = ""
    @State private var points = UserManager.shared.points.formatted()
    @State private var temperature = ""
    private let network = NetworkManager()
    @State private var alertShow = false   //얼럿
    @State private var errAlertShow = false // 오류 얼럿
    
    var visibleRegion: MKCoordinateRegion = MKCoordinateRegion()
    var body: some View {
        VStack {
            textFiledView(text: "닉네임", textFiled: $nick)
            textFiledView(text: "위치", textFiled: $location)
            textFiledView(text: "lon", textFiled: $lon)
            textFiledView(text: "lat", textFiled: $lat)
            textFiledView(text: "포인트", textFiled: $points)
            textFiledView(text: "온도", textFiled: $temperature)
            Button {
                // Action
                Task {
                    let body = UpdateUserBody(nick: nick, info1: location, info2: String(lon), info3: String(lat), info4: points, info5: "12")
                    do {
                        let result = try await network.requestDTO(target: .user(.updateMyProfile(body: body, boundary: UUID().uuidString)), of: MyProfileDTO.self)
                        setProfile(profile: result.toDomain())
                        print("프로필 세팅 완료~~")
                        alertShow.toggle()
                    } catch {
                        print("프로필 설정 오류 발생!!!")
                        errAlertShow.toggle()
                    }
                }
            } label: {
                Text("저장하기")
            }
            .onAppear {
                lon = String(visibleRegion.center.longitude)
                lat = String(visibleRegion.center.latitude)
            }
            .alert("게시글 작성완료!", isPresented: $alertShow) {
                Button("확인") {
                    coordinator.pop()
                }
            }
            .alert("게시글 작성 오류 발생!", isPresented: $errAlertShow) {
                Button("확인") {}
            }
        }
    }
}
private extension SettingView {
    func textFiledView(text: String, textFiled: Binding<String>) -> some View {
        HStack {
            Text(text)
            TextField("\(text) 입력", text: textFiled)
        }
    }
    func setProfile(profile: ProfileModel) {
        UserManager.shared.userNick = profile.nick
        UserManager.shared.roadAddress = profile.address
        UserManager.shared.lon = profile.location.lon
        UserManager.shared.lat = profile.location.lat
        UserManager.shared.points = profile.point
        //UserManager.shared. = profile.address
        
    }
    
}
#Preview {
    SettingView()
}
