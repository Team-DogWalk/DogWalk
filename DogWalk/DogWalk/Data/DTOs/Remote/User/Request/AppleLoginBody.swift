//
//  AppleLoginBody.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 애플 로그인 요청 (Request)
struct AppleLoginBody: Encodable {
    let idToken: String
    let nick: String
}
