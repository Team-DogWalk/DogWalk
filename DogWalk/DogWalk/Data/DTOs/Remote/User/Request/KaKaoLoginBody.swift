//
//  KaKaoLoginBody.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 카카오 로그인 요청 (Request)
struct KaKaoLoginBody: Encodable {
    let oauthToken: String
}
