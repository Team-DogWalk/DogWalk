//
//  UserDefaults.swift
//  DogWalk
//
//  Created by junehee, 김윤우 on 10/29/24.
//

import Foundation

enum UserDefaultsKeys: String {
    case isUser              // 유저 여부 - 첫 화면 핸들링 위함
    case userID              // ID
    case userNick            // 닉네임
    case lon                 // 위도
    case lat                 // 경도
    case roadAddress         // 도로명 주소
    case points              // 포인트
    case totalWalkTime       // 산책시간
    case postCount           // 게시물 작성 횟수
    case gender              // 성별
    case acess               // acess token
    case refresh             // refresh token
    case imageCache
}

@propertyWrapper
struct UserDefault<T> {
    let key: UserDefaultsKeys
    let defaultValue: T
    let storage: UserDefaults
    
    init(key: UserDefaultsKeys, defaultValue: T, storage: UserDefaults = .standard) {
       self.key = key
       self.defaultValue = defaultValue
       self.storage = storage
   }
    
    var wrappedValue: T {
        get { self.storage.object(forKey: key.rawValue) as? T ?? self.defaultValue}
        set { self.storage.set(newValue, forKey: key.rawValue)}
    }
}
