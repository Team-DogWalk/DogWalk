//
//  ChattingRoomUseCase.swift
//  DogWalk
//
//  Created by junehee on 11/19/24.
//

import Foundation
import Combine
import CoreData

/**
 채팅방
 
 # 채팅방 첫 입장 시
 1) 채팅방 입장 시 roomID를 받아 DB에 저장된 채팅방을 찾고, 해당 채팅방의 모든 메세지 불러와서 변수에 저장
 2) 저장된 메세지 중 가장 마지막 메세지를 기반으로, 서버에 이후 메세지 정보 호출 (배열 형태로 가져옴)
 3) 응답받은 메세지 배열을 다시 해당 채팅방 DB에 저장
 4) DBDP 업데이트된 최신 메세지들을 다시 불러와 변수에 저장 후, 화면에 렌더링
 5) 소켓 연결
 
 # 채팅 보낼 때
 1) 서버에 채팅 보내기 요청
 2) 요청 성공하면, 응답 받은 데이터를 DB에 저장
 
 # 채팅 받을 때
 1) DB에서 불러와 변수에 저장해둔 모든 메세지 중 마지막 메세지의 날짜 체크
 */

/**
 
 */
protocol ChattingRoomUseCase {
    var chattingSubject: PassthroughSubject<[ChattingModel], Never> { get }
    
    func getChattingData(roomID: String) -> [ChattingModel]
    func getCursorDate(roomID: String) -> String
    func fetchChattingData(roomID: String, cursorDate: String) async throws -> [ChattingModel]
    func updateChattingData(roomID: String, data: [ChattingModel])
    func getAllChattingData(roomID: String) -> [ChattingModel]
    func openSocket(roomID: String)
    func postChattingImage(roomID: String, image: Data) async throws -> FileModel
    func sendMessage(roomID: String, type: MessageType, content: String) async throws  -> ChattingModel
    func closeSocket()
    func reconnectSocket(roomID: String)
}

final class DefaultChattingRoomUseCase: ChattingRoomUseCase {
    private let network = NetworkManager()
    private var socket: SocketProvider
    private let chatRepository = ChatRepository.shared
    
    let chattingSubject = PassthroughSubject<[ChattingModel], Never>()
    private var cancellable = Set<AnyCancellable>()
    
    init(roomID: String) {
        self.socket = SocketIOManager(roomID: roomID)
        self.socket.socketSubject
//            .receive(on: RunLoop.main)
            .sink { error in
                print("ChattingSubject ERROR", error)
            } receiveValue: { dm in
                print("📥 Socket received data: \(dm)")
                if let image = dm.files.first, image.isEmpty { // 비어있으면 텍스트 채팅
                    self.updateChattingData(roomID: roomID, type: .text, data: dm)
                } else {
                    // 안 비어어있으면 사진을 보낸 채팅
                    self.updateChattingData(roomID: roomID, type: .image, data: dm)
                }
            }
            .store(in: &cancellable)
    }
    
    // DB에서 기존 대화 내역 가져오기
    func getChattingData(roomID: String) -> [ChattingModel] {
        return chatRepository.fetchMessages(for: roomID)}
    
    // DB에서 최신 대화 날짜 가져오기
    func getCursorDate(roomID: String) -> String {
        let room = chatRepository.fetchChatRoom(roomID: roomID)
        guard let updateAt = room?.updatedAt else { return  "2024-05-06T05:13:54.357Z" }
        print("UpdateAt123", updateAt)
        print(room?.lastChat ?? "DB에서 최신 대화 날짜 가져오기 실패")
        print("UpdateAt", updateAt)
        return updateAt
    }
    
    // cursor_date 기반으로 서버에 최신 대화 내역 요청
    func fetchChattingData(roomID: String, cursorDate: String) async throws -> [ChattingModel] {
        do {
            let query = GetChatListQuery(cursor_date: "")
            let DTO = try await network.requestDTO(target: .chat(.getChatList(roomId: roomID, query: query)), of: ChattingResponseDTO.self)
            let chattingModels = DTO.toDomain()
            print("Fetched Chatting Models from Server: \(chattingModels)")
            return chattingModels
        } catch {
            print("Failed to fetch chatting data from server: \(error)")
            throw error
        }
    }
    
     // 서버에서 응답 받은 최신 대화 내용을 DB에 업데이트
    func updateChattingData(roomID: String, data: [ChattingModel]) {
        // 1. 채팅방 가져오기
        guard chatRepository.fetchChatRoom(roomID: roomID) != nil else {
//            print("❌ Chat room not found for ID: \(roomID)")
            return
        }
        print("updateChattingData", data)
        // 2. 기존 메시지 가져오기
        let existingMessages = chatRepository.fetchMessages(for: roomID)
        let existingChatIDs = Set(existingMessages.map { $0.chatID })

        // 3. 새로운 메시지 필터링 및 저장
        var newMessages: [CoreDataChatMessage] = []

        for msg in data where !existingChatIDs.contains(msg.chatID) {
            if let createdMessage = chatRepository.createChatMessage(chatRoomID: roomID, messageData: msg) {
                print("✅ Message created successfully: \(createdMessage.chatID ?? "Unknown ID")")
                newMessages.append(createdMessage)
            } else {
                print("❌ Failed to create message for chatID: \(msg.chatID)")
            }
        }

        // 4. 새로운 메시지가 없는 경우 종료
        guard !newMessages.isEmpty else {
//           print("❌ No new messages were added for RoomID: \(roomID)")
            return
        }

        // 5. 채팅방 업데이트
        chatRepository.updateChatRoom(chatRoomID: roomID, with: newMessages)

        // 6. 최종 메시지 목록 출력
        let allMessages = chatRepository.fetchMessages(for: roomID)
        print("✅ Updated Messages in DB for RoomID \(roomID): \(allMessages)")
    }
    
    // 소켓에서 받은 대화 내용을 DB에 업데이트
    func updateChattingData(roomID: String, type: MessageType, data: SocketDMModel) {
        // 1. 채팅방 가져오기
        guard chatRepository.fetchChatRoom(roomID: roomID) != nil else {
            print("Chat room not found for ID: \(roomID)")
            return
        }
        
        // 2. SocketDMModel 데이터를 UserModel로 변환
        let senderModel = UserModel(
            userID: data.sender.userID,
            nick: data.sender.nick,
            profileImage: data.sender.profileImage
        )
//        print("📥 Received files: \(data.files)")

        // 3. 채팅 메시지 생성 및 추가
        let _ = chatRepository.createChatMessage(
            chatRoomID: roomID,
            messageData: ChattingModel(
                chatID: data.chatID,
                roomID: roomID,
                type: type,
                content: data.content,
                createdAt: data.createdAt,
                sender: senderModel,
                files: data.files
            )
        )
       
        // 4. 채팅방 메시지 리스트 업데이트 후 Subject 전송
        chattingSubject.send(chatRepository.fetchMessages(for: roomID))
//        print("채팅 데이터가 업데이트되었습니다.")
    }
    
    
    // DB에서 전체 대화 내용을 가져와 View 반영
    func getAllChattingData(roomID: String) -> [ChattingModel] {
        return chatRepository.fetchAllMessages(for: roomID)
    }
    
    // 소켓 열기
    func openSocket(roomID: String) {
        socket.connect()
    }
    
    func reconnectSocket(roomID: String) {
        print(#function)
        socket = SocketIOManager(roomID: roomID)
        socket.socketSubject
            .receive(on: RunLoop.main)
            .sink { error in
                print("ChattingSubject ERROR", error)
            } receiveValue: { dm in
                print("📥 Socket received data: \(dm)")
                if let image = dm.files.first, image.isEmpty { // 비어있으면 텍스트 채팅
                    self.updateChattingData(roomID: roomID, type: .text, data: dm)
                } else {
                    // 안 비어어있으면 사진을 보낸 채팅
                    self.updateChattingData(roomID: roomID, type: .image, data: dm)
                }
            }
            .store(in: &cancellable)
        socket.connect()
    }
    
    // 텍스트 이미지(URL String) 채팅 보내기
    func sendMessage(roomID: String, type: MessageType, content: String) async throws  -> ChattingModel {
        do {
            let body: SendChatBody
            switch type {
            case .text:
                body = SendChatBody(content: content, files: [])
            case .image:
                body = SendChatBody(content: "", files: [content])
            }
            print("바디야 잘 ㄷ ㅡㄹ어가니?", body)
            
            let DTO = try await network.requestDTO(target: .chat(.sendChat(roomId: roomID, body: body)), of: ChattingDTO.self)
            print("DDDDTTTTOOOO", DTO.toDomain())
            return DTO.toDomain()
        } catch {
            print(#function, error)
            throw error
        }
    }
    
    // 이미지 보내기
    func postChattingImage(roomID: String, image: Data) async throws -> FileModel {
        do {
            let body = ImageUploadBody(files: [image])
            let data = try await network.requestDTO(target: .post(.files(body: body)), of: FileDTO.self)
            return data.toDomain()
        } catch {
            print(#function, error)
            throw error
        }
    }
    
    // 소켓 닫기
    func closeSocket() {
        socket.disconnect()
    }
}
