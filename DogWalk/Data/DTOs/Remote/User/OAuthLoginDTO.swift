//
//  OAuthLoginDTO.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 카카오 & 애플 로그인 응답 (Response)
struct OAuthLoginDTO: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let profileImage: String?
    let accessToken: String
    let refreshToken: String
}

extension OAuthLoginDTO {
    func toDomain() -> OAuthLoginModel {
        return OAuthLoginModel(userID: self.user_id,
                               email: self.email,
                               nick: self.nick,
                               profileImage: self.profileImage ?? "",
                               accessToken: self.accessToken,
                               refreshToken: self.refreshToken)
    }
}

struct OAuthLoginModel {
    let userID: String
    let email: String
    let nick: String
    let profileImage: String
    let accessToken: String
    let refreshToken: String
}
