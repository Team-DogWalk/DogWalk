//
//  NetworkError.swift
//  DogWalk
//
//  Created by junehee on 11/1/24.
//

import Foundation

/** `HTTP Status Code`
 `401` 인증할 수 없는 액세스 토큰 (공백/한글 포함 등)
 `403` Forbidden. 접근 권한 없음. user id 조회 불가.
 `419` 액세스 토큰 만료. 토큰 갱신 필요. (refresh)
 `420` Header에 SesacKey가 없거나 틀린 경우
 `421` Header에 ProductId가 로그인 중인 계정에 대해 유효하지 않은 경우
 `429` 서버 과호출
 `444` 비정상 URL
 `500` 서버 에러
*/

enum NetworkError: Int, Error {
    case InvalidToken = 401
    case Forbidden = 403
    case ExpiredAccessToken = 419
    case NoSesacKeyInHeader = 420
    case NoProductIDInHeader = 421
    case OverCall = 429
    case InvalidURL = 444
    case ServerError = 500
    
    // 👇여기부터는 새싹에서 정의한 에러가 아니라, 내부적으로 네트워크 통신 호출 로직에서 필요한 에러 상황입니다.
    case InvalidRequest
    case InvalidResponse
    case DecodingError
    case UnknownError
}