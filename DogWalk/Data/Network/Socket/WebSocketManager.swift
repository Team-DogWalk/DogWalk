//
//  WebSocketManager.swift
//  DogWalk
//
//  Created by junehee on 11/14/24.
//

import Foundation
import Combine

protocol SocketProvider {
    func open() throws
    func send(type: MessageType, text: String?, image: Data?, completion: @escaping (Result<String, WebSocketError>) -> Void)
    func receive(completion: @escaping (Result<any Equatable, WebSocketError>) -> Void)
    func close()
}

/**
 WebSocket의 delegate는 NSObject타입 → NSObject를 서브클래싱
 */
final class WebSocketManager: NSObject, SocketProvider {
    private var webSocket: URLSessionWebSocketTask? {
        didSet {
            print("WebSocket didSet")
            oldValue?.cancel(with: .goingAway, reason: nil)
        }
    }
    
    var timer: Timer?
    
    // 웹소켓 연결
    /// 주어진 URL을 이용해 WebSocketTask 생성 후 연결
    func open() throws {
        let testURL = "ws://slp2.sesac.co.kr:34593/v1/chats/673313242cced3080561033c"
        guard let URL = URL(string: testURL) else { throw WebSocketError.InvalidURL }
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: nil)
        webSocket = session.webSocketTask(with: URL)
        webSocket?.resume()
    }
    
    
    // 메세지 보내기 (송신)
    /// URLSessionWebSocketTask의  send() 메서드를 활용해 메세지를 보내고, completionHandler를 통해 결과를 처리
    func send(type: MessageType, text: String?, image: Data?, completion: @escaping (Result<String, WebSocketError>) -> Void) {
        let message: URLSessionWebSocketTask.Message
        
        switch type {
        case .text:
            if let text = text {
                message = .string(text)
            } else {
                completion(.failure(.InvalidText))
                return
            }
        case .image:
            if let data = image { 
                message = .data(data)
            } else {
                completion(.failure(.InvalidData))
                return
            }
        }
        
        webSocket?.send(message) { error in
            if let error = error {
                print("🚨 메세지 전송 실패")
                completion(.failure(.MessageSendFailed))
            } else {
                let result = type == .text ? "✨ 텍스트 메세지 전송 성공" : "✨ 이미지 메세지 전송 성공"
                completion(.success(result))
            }
        }
    }
    
    // 메세지 받기 (수신)
    /// URLSessionWebSocketTask의 receive() 메서드를 활용해 메세지를 받고, completionHandler를 통해 결과를 처리
    func receive(completion: @escaping (Result<any Equatable, WebSocketError>) -> Void) {
        webSocket?.receive(completionHandler: { result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("✨ 텍스트 메세지 수신 성공")
                    print(text)
                    completion(.success(text))
                case .data(let image):
                    print("✨ 이미지 메세지 수신 성공")
                    print(image)
                    completion(.success(image))
                @unknown default:
                    print("🚨 알 수 없는 수신 오류")
                    completion(.failure(.UnknownError))
                }
            case .failure(let error):
                print("🚨 메세지 수신 실패", error)
            }
            self.receive(completion: completion)
        })
    }
    
    // 웹소켓 닫기
    /// URLSessionWebSocketTask의 cancel(with: reason:) 메서드를 활용해 웹 소켓 연결을 취소
    /// `with`: 종료 상태 코드 (`goingAway`를 사용해 정상적인 종료 처리)
    /// `reason`: 연결을 종료하는 이유 설명
    func close() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
    }
    
    func startPing() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: 10,
            repeats: true,
            block: { [weak self] _ in self?.ping() }
        )
    }
    
    func ping() {
        webSocket?.sendPing(pongReceiveHandler: { [weak self] error in
            guard let error = error else {
                print(#function, WebSocketError.UnknownError)
                return
            }
            print("🚨 Ping Failed!", error)
            self?.startPing()
        })
    }
}

extension WebSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("✅ Socket OPEN")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("⚠️ Socket CLOSED")
    }
}
