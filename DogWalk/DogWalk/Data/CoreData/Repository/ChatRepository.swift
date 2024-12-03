//
//  ChatRepository.swift
//  DogWalk
//
//  Created by 김윤우 on 11/21/24.
//

import Foundation
import CoreData

final class ChatRepository {
    static let shared = ChatRepository(context: CoreDataManager.shared.viewContext)  // 싱글턴 인스턴스
    
    private let managedObjectContext: NSManagedObjectContext
    
    private init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }

    func createChatRoom(chatRoomData: ChattingRoomModel) {
        let request: NSFetchRequest<CoreChatRoom> = CoreChatRoom.fetchRequest()
        request.predicate = NSPredicate(format: "roomID == %@", chatRoomData.roomID) // roomID로 기존 채팅방을 찾음

        do {
            // 기존 채팅방이 있는지 확인
            if let existingChatRoom = try managedObjectContext.fetch(request).first {
                // 기존 채팅방이 있다면 업데이트
                existingChatRoom.createdAt = chatRoomData.createAt
                existingChatRoom.meUserID = chatRoomData.me.userID
                existingChatRoom.meNick = chatRoomData.me.nick
                existingChatRoom.meProfileImage = chatRoomData.me.profileImage
                existingChatRoom.ohterUserID = chatRoomData.otherUser.userID
                existingChatRoom.otherNick = chatRoomData.otherUser.nick
                existingChatRoom.otherProfileImage = chatRoomData.otherUser.profileImage
                existingChatRoom.lastChat = CoreLastChat(
                                   chatID: chatRoomData.lastChat?.chatID ?? "",
                                   type: chatRoomData.lastChat?.type.rawValue ?? "",
                                   lastChat: chatRoomData.lastChat?.lastChat ?? "",
                                   sender: CoreUserModel(
                                       userID: chatRoomData.lastChat?.sender.userID ?? "",
                                       nick: chatRoomData.lastChat?.sender.nick ?? "",
                                       profileImage: chatRoomData.lastChat?.sender.profileImage ?? ""
                                   )
                               )
                
                existingChatRoom.updateAt = chatRoomData.updatedAt
                print("Chat room updated.")
            } else {
                // 기존 채팅방이 없으면 새로 생성
                let newChatRoom = CoreChatRoom(context: managedObjectContext)
                newChatRoom.roomID = chatRoomData.roomID
                newChatRoom.createdAt = chatRoomData.createAt
                newChatRoom.meUserID = chatRoomData.me.userID
                newChatRoom.meNick = chatRoomData.me.nick
                newChatRoom.meProfileImage = chatRoomData.me.profileImage
                newChatRoom.ohterUserID = chatRoomData.otherUser.userID
                newChatRoom.otherNick = chatRoomData.otherUser.nick
                newChatRoom.otherProfileImage = chatRoomData.otherUser.profileImage
                newChatRoom.lastChat = CoreLastChat(
                                          chatID: chatRoomData.lastChat?.chatID ?? "",
                                          type: chatRoomData.lastChat?.type.rawValue ?? "text",
                                          lastChat: chatRoomData.lastChat?.lastChat ?? "",
                                          sender: CoreUserModel(
                                              userID: chatRoomData.lastChat?.sender.userID ?? "",
                                              nick: chatRoomData.lastChat?.sender.nick ?? "",
                                              profileImage: chatRoomData.lastChat?.sender.profileImage ?? ""
                                          )
                                      )
                newChatRoom.updateAt = chatRoomData.updatedAt
                newChatRoom.messages = []

                print("New chat room created.")
            }

            // 변경 사항 저장
            saveContext()
        } catch {
            print("Error fetching chat room: \(error.localizedDescription)")
        }
    }

    // 메시지 생성
    func createChatMessage(chatID: String, content: String, sender: UserModel, files: [String], in chatRoom: CoreChatRoom) -> CoreChatMessage {
        let newMessage = CoreChatMessage()
        newMessage.chatID = chatID
        newMessage.roomID = chatRoom.roomID
        newMessage.type = MessageType.text.rawValue // 필요 시 수정 가능
        newMessage.message = content
        newMessage.senderUserID = sender.userID
        newMessage.senderUserNick = sender.nick
        newMessage.senderProfileImage = sender.profileImage
        newMessage.files = files
        return newMessage
    }

    // 채팅방 업데이트
    func updateChatRoom(chatRoomID: String, newMessages: [CoreChatMessage]) {
        let request: NSFetchRequest<CoreChatRoom> = CoreChatRoom.fetchRequest()
        request.predicate = NSPredicate(format: "roomID == %@", chatRoomID)

        do {
            if let chatRoom = try managedObjectContext.fetch(request).first {
                var messages = chatRoom.messages ?? []
                messages.append(contentsOf: newMessages)
                chatRoom.messages = messages
                saveContext()
                print("Chat room updated successfully.")
            } else {
                print("Chat room not found for ID: \(chatRoomID)")
            }
        } catch {
            print("Error updating chat room: \(error.localizedDescription)")
        }
    }
    
    // 전체 채팅방 가져오기
    func fetchAllChatRoom() -> [ChattingRoomModel]? {
        let request: NSFetchRequest<CoreChatRoom> = CoreChatRoom.fetchRequest()
        do {
            let coreChatRooms = try managedObjectContext.fetch(request)
            return coreChatRooms.map { chatRoom in
                return ChattingRoomModel(roomID: chatRoom.roomID ?? "룸아이디 없음",
                                         createAt: chatRoom.createdAt ?? "",
                                         updatedAt: chatRoom.updateAt ?? "" ,
                                         me: UserModel(userID: chatRoom.meUserID ?? "내 아디 없음" ,
                                                       nick: chatRoom.meNick ?? "내 닉 없음",
                                                       profileImage: chatRoom.meProfileImage ?? "내이미지없음"),
                                         otherUser: UserModel(userID: chatRoom.ohterUserID ?? "내 아디 없음", 
                                                              nick: chatRoom.otherNick ?? "내 닉 없음",
                                                              profileImage: chatRoom.otherProfileImage ?? "내이미지없음"),
                                         lastChat: LastChatModel(type: MessageType(rawValue: chatRoom.lastChat?.type ?? "텍스트") ?? .text,
                                                                 chatID: chatRoom.lastChat?.chatID ?? "",
                                                                 lastChat: chatRoom.lastChat?.lastChat ?? "",
                                                                 sender: UserModel(userID: chatRoom.lastChat?.sender?.userID ?? "",
                                                                                   nick: chatRoom.lastChat?.sender?.nick ?? "",
                                                                                   profileImage: chatRoom.lastChat?.sender?.profileImage ?? "")))
            }
        } catch {
            return nil
        }
    }
    
    // RoomID로 특정 채팅방 가져오기
    func fetchChatRoom(chatRoomID: String) -> CoreChatRoom? {
        let request: NSFetchRequest<CoreChatRoom> = CoreChatRoom.fetchRequest()
        request.predicate = NSPredicate(format: "roomID == %@", chatRoomID)

        do {
            return try managedObjectContext.fetch(request).first
        } catch {
            print("Error fetching chat room: \(error.localizedDescription)")
            return nil
        }
    }
    
    

    // 모든 메시지 가져오기
    func fetchAllMessages(for chatRoomID: String) -> [ChattingModel] {
        let request: NSFetchRequest<CoreChatRoom> = CoreChatRoom.fetchRequest()
        request.predicate = NSPredicate(format: "roomID == %@", chatRoomID)

        do {
            if let chatRoom = try managedObjectContext.fetch(request).first {
                let coreMessages = chatRoom.messages ?? []
                return coreMessages.map(convertToChattingModel)
            } else {
                print("Chat room not found for ID: \(chatRoomID)")
                return []
            }
        } catch {
            print("Error fetching messages: \(error.localizedDescription)")
            return []
        }
    }

    // 특정 roomID로 채팅방 생성
    func createSpecificChatRoom(roomID: String) {
        let chatRoomData = ChattingRoomModel(
            roomID: roomID, // 특정 roomID 사용
            createAt: "",  // 생성 일자
            updatedAt: "", // 업데이트 일자
            me: UserModel(userID: "", nick: "", profileImage: ""), // 사용자 정보
            otherUser: UserModel(userID: "", nick: "", profileImage: ""), // 다른 사용자 정보
            lastChat: nil // 마지막 채팅 (없다면 nil)
        )
        
        createChatRoom(chatRoomData: chatRoomData) // 채팅방 생성
        print("Specific chat room created with ID: \(chatRoomData.roomID)")
    }

    // 메시지 변환
    private func convertToChattingModel(_ coreMessage: CoreChatMessage) -> ChattingModel {
        return ChattingModel(
            chatID: coreMessage.chatID ?? "",
            roomID: coreMessage.roomID ?? "",
            type: MessageType(rawValue: coreMessage.type ?? "text") ?? .text,
            content: coreMessage.message ?? "",
            createdAt: "",
            sender: UserModel(
                userID: coreMessage.senderUserID ?? "",
                nick: coreMessage.senderUserNick ?? "",
                profileImage: coreMessage.senderProfileImage ?? ""
            ),
            files: coreMessage.files ?? []
        )
    }
    
    // 채팅방 전체 삭제
    func deleteAllChatRooms() {
        let request: NSFetchRequest<CoreChatRoom> = CoreChatRoom.fetchRequest()

        do {
            // 모든 채팅방 가져오기
            let chatRooms = try managedObjectContext.fetch(request)

            // 각 채팅방 삭제
            for chatRoom in chatRooms {
                managedObjectContext.delete(chatRoom)
            }

            // 변경 사항 저장
            saveContext()
            print("All chat rooms deleted successfully.")
        } catch {
            print("Error deleting all chat rooms: \(error.localizedDescription)")
        }
    }

    // 컨텍스트 저장
    private func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}
