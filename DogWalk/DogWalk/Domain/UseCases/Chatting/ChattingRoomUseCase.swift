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
    func sendTextMessage(roomID: String, message: String) async throws -> ChattingModel
    func sendImageMessage(roomID: String, image: Data) async throws -> ChattingFilesModel
    func closeSocket()
    func testSubject(roomID: String) -> [ChattingModel]
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
            .receive(on: RunLoop.main)
            .sink { error in
                print("ChattingSubject ERROR", error)
            } receiveValue: { socketDMModel in
                self.updateChattingData(roomID: roomID, data: socketDMModel)
            }
            .store(in: &cancellable)

    }
    
    // DB에서 기존 대화 내역 가져오기
    func getChattingData(roomID: String) -> [ChattingModel] {
        return chatRepository.fetchAllMessages(for: roomID)
    }
    
    // DB에서 최신 대화 날짜 가져오기
    func getCursorDate(roomID: String) -> String {
        let room = chatRepository.fetchChatRoom(chatRoomID: roomID)
        guard let updateAt = room?.updateAt else { return  "2024-05-06T05:13:54.357Z" }
        print("UpdateAt", updateAt)
        return updateAt
    }
    
    // cursor_date 기반으로 서버에 최신 대화 내역 요청
    func fetchChattingData(roomID: String, cursorDate: String) async throws -> [ChattingModel] {
        do {
            let query = GetChatListQuery(cursor_date: cursorDate)
            let DTO = try await network.requestDTO(target: .chat(.getChatList(roomId: roomID, query: query)), of: ChattingResponseDTO.self)
            return DTO.toDomain()
        } catch {
            print(#function, "최신 대화 요청 실패")
            throw error
        }
    }
    
     // 서버에서 응답 받은 최신 대화 내용을 DB에 업데이트
    func updateChattingData(roomID: String, data: [ChattingModel]) {
        // 1. CoreData에서 채팅방 가지고 오고
        guard let chatRoom = chatRepository.fetchChatRoom(chatRoomID: roomID) else {
            print("Chat room not found for ID: \(roomID)")
            return
        }

        // ChattingModel 데이터를 CoreChatMessage로 변환
        let newMessages = data.map { msg in
            chatRepository.createChatMessage(
                chatID: msg.chatID,
                content: msg.content,
                sender: msg.sender,
                files: msg.files,
                in: chatRoom
            )
        }
        // 채팅방 메시지 업데이트
        chatRepository.updateChatRoom(chatRoomID: roomID, newMessages: newMessages)
    }
    
    // 소켓에서 받은 대화 내용을 DB에 업데이트
    func updateChattingData(roomID: String, data: SocketDMModel) {
        guard let chatRoom = chatRepository.fetchChatRoom(chatRoomID: roomID) else {
            print("Chat room not found for ID: \(roomID)")
            return
        }
        
        let socketMessage = chatRepository.createChatMessage(
            chatID: data.chatID,
            content: data.content,
            sender: UserModel(userID: data.sender.userID,
                              nick: data.sender.nick,
                              profileImage: data.sender.profileImage),
            files: data.files,
            in: chatRoom
        )
        
        chatRepository.updateChatRoom(chatRoomID: roomID, newMessages: [socketMessage])
        chattingSubject.send(chatRepository.fetchAllMessages(for: roomID))
    }
    
    
    // DB에서 전체 대화 내용을 가져와 View 반영
    func getAllChattingData(roomID: String) -> [ChattingModel] {
        return chatRepository.fetchAllMessages(for: roomID)
    }
    
    // 소켓 열기
    func openSocket(roomID: String) {
        socket.connect()
    }
    
    // 텍스트 보내기
    func sendTextMessage(roomID: String, message: String) async throws  -> ChattingModel {
        do {
            let body = SendChatBody(content: message)
            let DTO = try await network.requestDTO(target: .chat(.sendChat(roomId: roomID, body: body)), of: ChattingDTO.self)
            return DTO.toDomain()
        } catch {
            print(#function, error)
            throw error
        }
    }
    
    // 이미지 보내기
    func sendImageMessage(roomID: String, image: Data) async throws -> ChattingFilesModel {
        do {
            let body = PostFileBody(files: [image])
            let data = try await network.requestDTO(target: .chat(.postChatFiles(roomId: roomID, body: body)), of: ChattingFilesModel.self)
            return data
        } catch {
            print(#function, error)
            throw error
        }
    }
    
    // 소켓 닫기
    func closeSocket() {
        socket.disconnect()
    }
    
    func testSubject(roomID: String) -> [ChattingModel] {
        var temp: [ChattingModel] = []
        
        self.socket.socketSubject
            .receive(on: RunLoop.main)
            .sink { error in
                print("ChattingSubject ERROR", error)
            } receiveValue: { [weak self] socketDMModel in
                self?.updateChattingData(roomID: roomID, data: socketDMModel)
                temp = self?.chatRepository.fetchAllMessages(for: roomID) ?? []
            }
            .store(in: &cancellable)
        
        return temp
    }
}
