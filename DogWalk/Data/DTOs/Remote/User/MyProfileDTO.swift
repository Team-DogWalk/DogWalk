//
//  MyProfileDTO.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 내 프로필 조회 응답 (Response)
struct MyProfileDTO: Decodable {
    let user_id: String
    // let email: String
    let nick: String
    let profileImage: String?
    // let phoneNum: String
    // let gender: String
    // let birthDay: String
    let info1: String                   // 주소
    let info2: String                   // 위도
    let info3: String                   // 경도
    let info4: String                   // 포인트
    let info5: String                   // 온도
    // let followers: [FollowDTO]
    // let following: [FollowDTO]
    // let posts: [String]
}

extension MyProfileDTO {
    func toDomain() -> ProfileModel {
        return ProfileModel(userID: self.user_id, 
                              nick: self.nick,
                              profileImage: self.profileImage ?? "",        // TODO: 기본 프로필 지정 필요한지 체크
                              address: self.info1,
                              location: GeolocationModel(lat: Double(self.info2) ?? 0.0, 
                                                         lon: Double(self.info3) ?? 0.0),
                              point: Int(self.info4) ?? 0,
                              rating: Double(self.info5) ?? 0.0)
    }
}

// 내 프로필 & 다른 유저 프로필 조회 모델 (UserModel과 다름!)
struct ProfileModel {
    let userID: String
    let nick: String
    let profileImage: String
    let address: String
    let location: GeolocationModel
    let point: Int
    let rating: Double
    // let email: String
    // let phoneNum: String
    // let gender: String
    // let birthDay: String
    // let followers: [FollowDTO]
    // let following: [FollowDTO]
    // let posts: [String]
}
