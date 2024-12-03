//
//  WebSocketError.swift
//  DogWalk
//
//  Created by junehee on 11/15/24.
//

import Foundation

enum SocketError: Error {
    case InvalidURL         // 웹 소켓을 연결할 URL이 잘못된 경우
    case InvalidText        // 웹 소켓으로 전송할 텍스트가 잘못된 경우
    case InvalidData        // 웹 소켓으로 전송할 데이터(이미지)가 잘못된 경우
    case MessageSendFailed  // 메세지 전송이 실패한 경우
    case UnknownError
}
