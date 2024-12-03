//
//  UserTarget.swift
//  DogWalk
//
//  Created by junehee on 11/2/24.
//

import Foundation

enum UserTarget {
    case emailLogin(body: EmailLoginBody)       // 이메일 로그인
    case kakaoLogin(body: KaKaoLoginBody)       // 카카오 로그인
    case appleLogin(body: AppleLoginBody)       // 애플 로그인
    case myProfile                              // 내 프로필 조회
    case userProfile(userId: String)            // 다른 유저 프로필 조회
    case withdraw                               // 회원탈퇴
    case updateMyProfile(body: UpdateUserBody, boundary: String)
}

extension UserTarget: TargetType {
    var baseURL: String {
        return APIKey.baseURL
    }
    
    var path: String {
        switch self {
        case .emailLogin:
            return "/users/login"
        case .kakaoLogin:
            return "/users/login/kakao"
        case .appleLogin:
            return "/users/login/apple"
        case .myProfile:
            return "/users/me/profile"
        case .userProfile(let userId):
            return "/users/\(userId)/profile"
        case .withdraw:
            return "/users/withdraw"
        case .updateMyProfile:
            return "/users/me/profile"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .emailLogin, .kakaoLogin, .appleLogin:
            return .post
        case .myProfile, .userProfile, .withdraw:
            return .get
        case .updateMyProfile:
            return .put
        }
    }
    
    var header: [String : String] {
        switch self {
            /// productId, application/json
        case .emailLogin, .kakaoLogin, .appleLogin:
            return [
                BaseHeader.productId.rawValue: APIKey.appID,
                BaseHeader.sesacKey.rawValue: APIKey.key,
                BaseHeader.contentType.rawValue: BaseHeader.json.rawValue,
            ]
            /// productId, application/json, AccessToken, SesacKey
        case .myProfile, .userProfile, .withdraw:
            return [
                BaseHeader.productId.rawValue: APIKey.appID,
                BaseHeader.contentType.rawValue: BaseHeader.json.rawValue,
                BaseHeader.authorization.rawValue: UserManager.shared.acess,
                BaseHeader.sesacKey.rawValue: APIKey.key
            ]
        case .updateMyProfile(_, let boundary):
            return [
                BaseHeader.productId.rawValue: APIKey.appID,
                BaseHeader.authorization.rawValue: UserManager.shared.acess,
                BaseHeader.sesacKey.rawValue: APIKey.key,
                BaseHeader.contentType.rawValue: BaseHeader.multipart.rawValue+"; boundary=\(boundary)",
            ]
        }
    }
    
    var query: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        let encoder = JSONEncoder()
        
        switch self {
        case .emailLogin(let body):
            do {
                let data = try encoder.encode(body)
                return data
            } catch {
                print("Body to JSON Encode Error", error)
                return nil
            }
        case .kakaoLogin(let body):
            do {
                let data = try encoder.encode(body)
                return data
            } catch {
                print("Body to JSON Encode Error", error)
                return nil
            }
        case .appleLogin(let body):
            do {
                let data = try encoder.encode(body)
                return data
            } catch {
                print("Body to JSON Encode Error", error)
                return nil
            }
        case .updateMyProfile(let body, let boundary):
            return createMultipartUserBody(parameters: body, boundary: boundary)
        default:
            return nil
        }
    }
    
    // var boundary: String {
    //     return nil
    // }
}
