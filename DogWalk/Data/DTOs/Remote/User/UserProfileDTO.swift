//
//  UserProfileDTO.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 다른 유저 프로필 조회 응답 (Response)
// email, phoneNum, gender, birthDay 값은 응답값에 포함X
struct UserProfileDTO: Decodable {
    let user_id: String
    let nick: String
    let profileImage: String
    let info1: String               // 주소
    let info2: String               // 위도
    let info3: String               // 경도
    let info4: String               // 포인트
    let info5: String               // 온도
    // let followers: [FollowDTO]
    // let following: [FollowDTO]
    // let posts: [String]
}

extension UserProfileDTO {
    func toDomain() -> ProfileModel {
        return ProfileModel(userID: self.user_id,
                              nick: self.nick, 
                              profileImage: self.profileImage,
                              address: self.info1,
                              location: GeolocationModel(lat: Double(self.info2) ?? 0.0,
                                                         lon: Double(self.info3) ?? 0.0),
                              point: Int(self.info4) ?? 0, 
                              rating: Double(self.info5) ?? 0.0)
    }
}
