//
//  AuthTarget.swift
//  DogWalk
//
//  Created by junehee on 11/1/24.
//

import Foundation

enum AuthTarget {
    case refreshToken    // 토큰 갱신
}

extension AuthTarget: TargetType {
    var baseURL: String {
        return APIKey.baseURL
    }
    
    var path: String {
        return "/auth/refresh"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var header: [String : String] {
        return [
            "accept":"application/json",
            BaseHeader.productId.rawValue: APIKey.appID,
            BaseHeader.refresh.rawValue: UserManager.shared.refresh,
            BaseHeader.authorization.rawValue: UserManager.shared.acess,
            BaseHeader.sesacKey.rawValue: APIKey.key
        ]
    }
    
    var query: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
    
    // var boundary: String {
    //     return nil
    // }
}
