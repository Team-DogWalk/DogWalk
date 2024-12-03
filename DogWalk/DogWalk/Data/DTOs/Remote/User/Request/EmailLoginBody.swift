//
//  EmailLoginBody.swift
//  DogWalk
//
//  Created by junehee on 11/11/24.
//

import Foundation

// 이메일 로그인 요청 (Request)
struct EmailLoginBody: Encodable {
    let email: String
    let password: String
}
