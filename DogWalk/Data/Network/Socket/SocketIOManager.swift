//
//  WebSocketManager.swift
//  DogWalk
//
//  Created by junehee on 11/14/24.
//

import Foundation
import Combine
import SocketIO

protocol SocketProvider {
    func connect()          // 소켓 연결
    func disconnect()       // 소켓 연결 해제
}

final class SocketIOManager: NSObject, SocketProvider {
    private var manager: SocketManager?
    var socket: SocketIOClient?
    
    // init(roomID: Int) {
    init(roomID: String) {
        super.init()
        createSocket(roomID: roomID)
        // socket = manager?.defaultSocket
        
        // 소켓 연결될 때 실행
        socket?.on(clientEvent: .connect) { data, ack in
            print("✨ Socket is Connected", data, ack)
        }
        
        // 소켓 채팅 듣는 메서드, 이벤트로 날아온 데이터를 수신
        // 데이터 수신 -> 디코딩 -> 모델 추가 -> 갱신
        socket?.on("dm") { dataArr, ack in
            print("📮 DM 수신", dataArr, ack)
            do {
                let data = dataArr[0]
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let decodedData = try JSONDecoder().decode(SocketDMDTO.self, from: jsonData)
                print("👇 Socket DecodedData")
                // self.messageClosure(decodeData: decodedData)
            } catch {
                print("🚨 채팅 데이터 디코딩 실패", error)
            }
        }
        
        // 소켓 해제될 때 실행
        socket?.on(clientEvent: .disconnect) { data, ack in
            print("⛓️‍💥 Socket is Disconnected", data, ack)
        }
    }
    
    // 채팅방 Socket 연결
    // private func createSocket(roomID: Int) {
    private func createSocket(roomID: String) {
        guard let baseURL = URL(string: APIKey.baseURL) else { return }
        self.manager = SocketManager(
            socketURL: baseURL, config: [
                .log(true), // 소켓 통신 중에 로그를 표시 유무
                .compress,  // 데이터를 압축해서 전송할 것인지
                .extraHeaders([BaseHeader.sesacKey.rawValue: APIKey.key, BaseHeader.authorization.rawValue: UserManager.shared.acess])  // 헤더를 포함해서 보낼 것인지
            ]
        )
        socket = manager?.socket(forNamespace: "\(APIKey.socket)\(roomID)")
    }

    func connect() {
        socket?.connect()
    }
    
    func disconnect() {
        socket?.disconnect()
        socket = nil
        manager = nil
    }
}



// MARK: - URLSession 시도 코드 (사용X - 추후 참고용으로 남겨두었습니다.)
// protocol WebSocketProvider {
//     func open() throws
//     func send(type: MessageType, text: String?, image: Data?, completion: @escaping (Result<String, SocketError>) -> Void)
//     func receive(completion: @escaping (Result<any Equatable, SocketError>) -> Void)
//     func close()
// }
/**
 WebSocket의 delegate는 NSObject타입 → NSObject를 서브클래싱
 */
// final class WebsSocketManager: NSObject, WebSocketProvider {
//     private var webSocket: URLSessionWebSocketTask? {
//         didSet {
//             print("WebSocket didSet")
//             oldValue?.cancel(with: .goingAway, reason: nil)
//         }
//     }
//     
//     var timer: Timer?
//     
//     // 웹소켓 연결
//     /// 주어진 URL을 이용해 WebSocketTask 생성 후 연결
//     func open() throws {
//         guard let URL = URL(string: APIKey.baseURL) else { throw SocketError.InvalidURL }
//         let session = URLSession(configuration: .default,
//                                  delegate: self,
//                                  delegateQueue: nil)
//         webSocket = session.webSocketTask(with: URL)
//         webSocket?.resume()
//     }
//     
//     
//     // 메세지 보내기 (송신)
//     /// URLSessionWebSocketTask의  send() 메서드를 활용해 메세지를 보내고, completionHandler를 통해 결과를 처리
//     func send(type: MessageType, text: String?, image: Data?, completion: @escaping (Result<String, SocketError>) -> Void) {
//         let message: URLSessionWebSocketTask.Message
//         
//         switch type {
//         case .text:
//             if let text = text {
//                 message = .string(text)
//             } else {
//                 completion(.failure(.InvalidText))
//                 return
//             }
//         case .image:
//             if let data = image { 
//                 message = .data(data)
//             } else {
//                 completion(.failure(.InvalidData))
//                 return
//             }
//         }
//         
//         webSocket?.send(message) { error in
//             if let error = error {
//                 print("🚨 메세지 전송 실패")
//                 completion(.failure(.MessageSendFailed))
//             } else {
//                 let result = type == .text ? "✨ 텍스트 메세지 전송 성공" : "✨ 이미지 메세지 전송 성공"
//                 completion(.success(result))
//             }
//         }
//     }
//     
//     // 메세지 받기 (수신)
//     /// URLSessionWebSocketTask의 receive() 메서드를 활용해 메세지를 받고, completionHandler를 통해 결과를 처리
//     func receive(completion: @escaping (Result<any Equatable, SocketError>) -> Void) {
//         webSocket?.receive(completionHandler: { result in
//             switch result {
//             case .success(let message):
//                 switch message {
//                 case .string(let text):
//                     print("✨ 텍스트 메세지 수신 성공")
//                     print(text)
//                     completion(.success(text))
//                 case .data(let image):
//                     print("✨ 이미지 메세지 수신 성공")
//                     print(image)
//                     completion(.success(image))
//                 @unknown default:
//                     print("🚨 알 수 없는 수신 오류")
//                     completion(.failure(.UnknownError))
//                 }
//             case .failure(let error):
//                 print("🚨 메세지 수신 실패", error)
//             }
//             self.receive(completion: completion)
//         })
//     }
//     
//     // 웹소켓 닫기
//     /// URLSessionWebSocketTask의 cancel(with: reason:) 메서드를 활용해 웹 소켓 연결을 취소
//     /// `with`: 종료 상태 코드 (`goingAway`를 사용해 정상적인 종료 처리)
//     /// `reason`: 연결을 종료하는 이유 설명
//     func close() {
//         webSocket?.cancel(with: .goingAway, reason: nil)
//         webSocket = nil
//     }
//     
//     func startPing() {
//         timer?.invalidate()
//         timer = Timer.scheduledTimer(
//             withTimeInterval: 10,
//             repeats: true,
//             block: { [weak self] _ in self?.ping() }
//         )
//     }
//     
//     func ping() {
//         webSocket?.sendPing(pongReceiveHandler: { [weak self] error in
//             guard let error = error else {
//                 print(#function, SocketError.UnknownError)
//                 return
//             }
//             print("🚨 Ping Failed!", error)
//             self?.startPing()
//         })
//     }
// }
// 
// extension WebsSocketManager: URLSessionWebSocketDelegate {
//     func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
//         print("✅ Socket OPEN")
//     }
//     
//     func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
//         print("⚠️ Socket CLOSED")
//     }
// }
