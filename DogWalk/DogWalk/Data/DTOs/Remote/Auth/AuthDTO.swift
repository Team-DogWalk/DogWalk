//
//  AuthDTO.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import Foundation

// 토큰 갱신 응답 데이터 (Response)
struct AuthDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}

extension AuthDTO {
    func toDomain() -> AuthModel {
        return AuthModel(accessToken: self.accessToken, refreshToken: self.refreshToken)
    }
}

struct AuthModel {
    let accessToken: String
    let refreshToken: String
}
