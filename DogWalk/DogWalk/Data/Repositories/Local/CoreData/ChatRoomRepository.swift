//
//  ChatRoomRepository.swift
//  DogWalk
//
//  Created by 김윤우 on 11/3/24.
//

import CoreData

final class ChatRoomRepository {
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    // 채팅방 추가
    func addChatRoom(id: String? = nil, participantNick: String? = nil) -> ChatRoom {
        let newChatRoom = ChatRoom(context: viewContext)
        newChatRoom.id = id ?? UUID().uuidString  // 기본값으로 UUID 사용
        newChatRoom.participantNick = participantNick
        newChatRoom.createdAt = Date()
        newChatRoom.updatedAt = Date()
        saveContext()
        return newChatRoom
    }
    
    // 모든 채팅방 조회
    func fetchChatRooms() -> [ChatRoom] {
        let request: NSFetchRequest<ChatRoom> = ChatRoom.fetchRequest()
        // 생성일 기준 정렬 추가
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch chat rooms: \(error)")
            return []
        }
    }
    
    // 특정 ID로 채팅방 조회
    func fetchChatRoom(withID id: String) -> ChatRoom? {
        let request: NSFetchRequest<ChatRoom> = ChatRoom.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        do {
            let rooms = try viewContext.fetch(request)
            return rooms.first
        } catch {
            print("Failed to fetch chat room: \(error)")
            return nil
        }
    }
    
    // 검색
    func searchChatRooms(matching searchText: String) -> [ChatRoom] {
        let request: NSFetchRequest<ChatRoom> = ChatRoom.fetchRequest()
        request.predicate = NSPredicate(
            format: "participantNick CONTAINS[cd] %@ OR id CONTAINS[cd] %@",
            searchText, searchText
        )
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to search chat rooms: \(error)")
            return []
        }
    }
    
    // 채팅방 업데이트
    func updateChatRoom(_ chatRoom: ChatRoom,
                        newParticipantNick: String? = nil,
                        newParticipantProfileImage: String? = nil) {
        if let participantNick = newParticipantNick {
            chatRoom.participantNick = participantNick
        }
        if let participantProfileImage = newParticipantProfileImage {
            chatRoom.participantProfileImage = participantProfileImage
        }
        chatRoom.updatedAt = Date()
        saveContext()
    }
    
    // 마지막 메세지 업데이트
    func updateLastMessage(in chatRoom: ChatRoom, message: ChatMessage) {
//        chatRoom.lastChatContent =
        chatRoom.updatedAt = message.timeStamp
        saveContext()
    }
    
    // Delete
    func deleteChatRoom(_ chatRoom: ChatRoom) {
        // 관련된 메시지들도 함께 삭제
        if let messages = chatRoom.messages as? Set<ChatMessage> {
            messages.forEach { viewContext.delete($0) }
        }
        viewContext.delete(chatRoom)
        saveContext()
    }
    
    // Delete - 여러 채팅방 일괄 삭제
    func deleteChatRooms(_ chatRooms: [ChatRoom]) {
        chatRooms.forEach { deleteChatRoom($0) }
    }
    
    // 저장
    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}
