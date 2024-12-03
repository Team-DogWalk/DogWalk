//
//  ChatTarget.swift
//  DogWalk
//
//  Created by junehee on 11/2/24.
//

import Foundation

enum ChatTarget {
    case newChatRoom(body: NewChatRoomBody)                         // 새로운 채팅방 생성
    case getChatRoomList                                            // 채팅방 리스트 조회
    case sendChat(roomId: String, body: SendChatBody)               // 채팅 보내기
    case getChatList(roomId: String, query: GetChatListQuery?)      // 채팅 내역 조회
    case postChatFiles(roomId: String, body: PostFileBody)      // 채팅방 파일 업로드
}

extension ChatTarget: TargetType {
    var baseURL: String {
        return APIKey.baseURL
    }
    
    var path: String {
        switch self {
        case .newChatRoom, .getChatRoomList:
            return "/chats"
        case .sendChat(let roomId, _), .getChatList(let roomId, _), .postChatFiles(let roomId, _):
            return "/chats/\(roomId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .newChatRoom, .sendChat, .postChatFiles:
            return .post
        case .getChatRoomList, .getChatList:
            return .get
        }
    }
    
    var header: [String : String] {
        switch self {
        case .newChatRoom, .getChatRoomList, .sendChat, .getChatList:
            return [
                BaseHeader.productId.rawValue: APIKey.appID,
                BaseHeader.contentType.rawValue: BaseHeader.json.rawValue, // json
                BaseHeader.authorization.rawValue: UserManager.shared.acess,
                BaseHeader.sesacKey.rawValue: APIKey.key
            ]
        case .postChatFiles:
            return [
                BaseHeader.productId.rawValue: APIKey.appID,
                BaseHeader.contentType.rawValue: BaseHeader.multipart.rawValue, // multipart-form
                BaseHeader.authorization.rawValue: UserManager.shared.acess,
                BaseHeader.sesacKey.rawValue: APIKey.key
            ]
        }
    }
    
    var query: [URLQueryItem]? {
        let encoder = JSONEncoder()
        
        switch self {
        case .getChatList(_, let query):
            do {
                let data = try encoder.encode(query)
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    return json.map { URLQueryItem(name: $0, value: "\($1)") }
                } else {
                    return nil
                }
            } catch {
                print("Query To JSON Encode Error!", error)
                return nil
            }
        default:
            return nil
        }
    }
    
    var body: Data? {
        let encoder = JSONEncoder()
        
        switch self {
        case .newChatRoom(let body):
            do {
                let data = try encoder.encode(body)
                return data
            } catch {
                print("Request Body To JSON Encode Error!", error)
                return nil
            }
        case .sendChat(_, let body):
            do {
                let data = try encoder.encode(body)
                return data
            } catch {
                print("Request Body To JSON Encode Error!", error)
                return nil
            }
        case .postChatFiles(_, let body):
            do {
                let data = try encoder.encode(body)
                return data
            } catch {
                print("Request Body To JSON Encode Error!", error)
                return nil
            }
        default:
            return nil
        }
    }
    
    // var boundary: String {
    //     return nil
    // }
}
