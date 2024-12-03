//
//  ChatRepository.swift
//  DogWalk
//
//  Created by 김윤우 on 11/23/24.
//

import CoreData

final class ChatRepository {
    static let shared = ChatRepository(context: CoreDataManager.shared.viewContext)
    
    private let managedObjectContext: NSManagedObjectContext
    
    private init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    // MARK: - 모든 채팅방 가져오기
    func fetchAllChatRoom() -> [ChattingRoomModel]? {
        let request: NSFetchRequest<CoreDataChatRoom> = CoreDataChatRoom.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)] // 최신순 정렬
        do {
            let coreDataChatRooms = try managedObjectContext.fetch(request)
            
//            // 메시지가 없는 채팅방 삭제
//            for chatRoom in coreDataChatRooms where chatRoom.message?.count == 0 {
//                managedObjectContext.delete(chatRoom)
//                print("메시지가 없는 채팅방 삭제됨: RoomID: \(chatRoom.roomID ?? "")")
//            }
            
            // 컨텍스트 저장
            saveContext()
            
            print("정렬된 채팅방:")
            coreDataChatRooms.forEach { print("RoomID: \($0.roomID ?? ""), UpdatedAt: \($0.updatedAt ?? "")") }
            
            return coreDataChatRooms.compactMap { toChattingRoomModel(chatRoom: $0) }
        } catch {
            print("채팅방 가져오기 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - 채팅방 생성
    func createChatRoom(chatRoomData: ChattingRoomModel) {
        if let existingChatRoom = fetchChatRoom(by: chatRoomData.roomID) {
            print("💬 기존 채팅방 데이터: \(existingChatRoom)")
            
            existingChatRoom.updatedAt = chatRoomData.updatedAt
            existingChatRoom.lastChat = chatRoomData.lastChat.map { createLastChat(lastChatModel: $0) }
            existingChatRoom.me = createCoreUser(userModel: chatRoomData.me)
            existingChatRoom.other = createCoreUser(userModel: chatRoomData.otherUser)
//            print("💾 업데이트된 채팅방 데이터: \(existingChatRoom)")
            saveContext()
//            print("이미 존재하는 채팅방 정보가 업데이트되었습니다. RoomID: \(chatRoomData.roomID)")
        } else {
            let newChatRoom = toCoreDataChatRoom(from: chatRoomData)
            print("💬 새 채팅방 데이터: \(newChatRoom)")
            
            managedObjectContext.insert(newChatRoom)
            saveContext()
            print("채팅방이 성공적으로 생성되었습니다. RoomID: \(chatRoomData.roomID)")
        }
    }
    
    // MARK: - 채팅방 업데이트
    func updateChatRoom(chatRoomID: String, with newMessages: [CoreDataChatMessage]) {
        guard let chatRoom = fetchChatRoom(by: chatRoomID) else {
            print("ID가 \(chatRoomID)인 채팅방을 찾을 수 없습니다.")
            return
        }
        
        // 새 메시지를 채팅방에 추가
        for message in newMessages {
            chatRoom.addToMessage(message)
        }
        
        // 마지막 메시지 업데이트
        if let lastMessage = newMessages.last {
            chatRoom.lastChat = createLastChat(lastChatModel: LastChatModel(
                type: MessageType(rawValue: lastMessage.type!) ?? .text,
                chatID: lastMessage.chatID ?? "",
                lastChat: lastMessage.content ?? "",
                sender: UserModel(
                    userID: lastMessage.sender?.userID ?? "",
                    nick: lastMessage.sender?.nick ?? "",
                    profileImage: lastMessage.sender?.profileImage ?? ""
                )
            ))
        }
        
        saveContext()
        print("채팅방이 성공적으로 업데이트되었습니다.")
    }
    
    // 특정 roomID로 채팅방 생성
    func createSpecificChatRoom(with roomID: String) {
        // roomID가 이미 존재하는지 확인
        if isChatRoomExist(roomID: roomID) {
            print("roomID가 \(roomID)인 채팅방이 이미 존재합니다.")
            return
        }
        
        // 새로운 채팅방 데이터 기본값 생성
        let newChatRoomData = ChattingRoomModel(
            roomID: roomID,
            createAt: "\(Date())",
            updatedAt: "\(Date())",
            me: UserModel(
                userID: "defaultMeID",
                nick: "defaultMeNick",
                profileImage: "defaultMeImage"
            ),
            otherUser: UserModel(
                userID: "defaultOtherID",
                nick: "defaultOtherNick",
                profileImage: "defaultOtherImage"
            ),
            lastChat: nil // 초기 생성 시에는 마지막 채팅이 없음
        )
        
        // 새로운 채팅방 생성
        createChatRoom(chatRoomData: newChatRoomData)
        print("roomID가 \(roomID)인 채팅방이 성공적으로 생성되었습니다.")
    }
    
    func fetchAllMessages(for roomID: String) -> [ChattingModel] {
        // CoreDataChatMessage 요청 생성
        let request: NSFetchRequest<CoreDataChatMessage> = CoreDataChatMessage.fetchRequest()
        request.predicate = NSPredicate(format: "roomID == %@", roomID) // roomID를 조건으로 설정
        
        do {
            // roomID에 해당하는 메시지 검색
            let coreMessages = try managedObjectContext.fetch(request)
            //            print("Repository fetchAllMessages")
            dump(coreMessages.map { $0.sender?.userID })
            // CoreDataChatMessage를 ChattingModel로 변환
            return coreMessages.map { coreMessage in
                ChattingModel(
                    chatID: coreMessage.chatID ?? "fetchAllMessages ChatID nil",
                    roomID: coreMessage.roomID ?? "fetchAllMessages roomID nil",
                    type: MessageType(rawValue: coreMessage.type ?? "text") ?? .text,
                    content: coreMessage.content ?? "fetchAllMessages content nil",
                    createdAt: coreMessage.createdAt ?? "",
                    sender: UserModel(
                        userID: coreMessage.sender?.userID ?? "fetchAllMessages sender UserID nil",
                        nick: coreMessage.sender?.nick ?? "fetchAllMessages sender UserID nil",
                        profileImage: coreMessage.sender?.profileImage ?? ""
                    ),
                    files: coreMessage.files ?? []
                )
            }
        } catch {
            print("roomID가 \(roomID)인 메시지 가져오기 실패: \(error.localizedDescription)")
            return []
        }
    }
    // MARK: - 채팅 메시지 생성
    func createChatMessage(chatRoomID: String, messageData: ChattingModel) -> CoreDataChatMessage? {
        guard let chatRoom = fetchChatRoom(by: chatRoomID) else {
            print("❌ ID가 \(chatRoomID)인 채팅방을 찾을 수 없습니다. 메시지를 생성하지 않습니다.")
            return nil
        }

        // 기존 메시지 확인
        let fetchRequest: NSFetchRequest<CoreDataChatMessage> = CoreDataChatMessage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "chatID == %@", messageData.chatID)
        if let existingMessage = try? managedObjectContext.fetch(fetchRequest), !existingMessage.isEmpty {
            print("❌ 이미 존재하는 메시지: \(messageData.chatID)")
            return existingMessage.first
        }

        // 새 메시지 생성
        let newMessage = CoreDataChatMessage(context: managedObjectContext)
        newMessage.chatID = messageData.chatID
        newMessage.roomID = chatRoomID
        newMessage.content = messageData.content
        newMessage.createdAt = messageData.createdAt
        newMessage.files = messageData.files
        newMessage.type = messageData.files.isEmpty ? "텍스트" : "이미지"
            // files 배열이 있는 경우에만 저장
            if !messageData.files.isEmpty {
                newMessage.files = messageData.files
            }

        let sender = createCoreUser(userModel: messageData.sender)
        newMessage.sender = sender
//        print("💾 messageData.files: \(messageData.files)")
        chatRoom.addToMessage(newMessage)
//        print( newMessage.type, "123123")
//        print("✅ 저장될 CoreData files: \(newMessage.files)")
        do {
            try managedObjectContext.save()
            print("✅ Chat message saved successfully.")
        } catch {
            print("❌ Failed to save context:", error)
            return nil
        }

        return newMessage
    }
    
    // MARK: - 특정 채팅방의 모든 메시지 가져오기
    func fetchMessages(for roomID: String) -> [ChattingModel] {
        let request: NSFetchRequest<CoreDataChatMessage> = CoreDataChatMessage.fetchRequest()
        request.predicate = NSPredicate(format: "roomID == %@", roomID)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        do {
            let coreMessages = try managedObjectContext.fetch(request)
            coreMessages.forEach { message in print("📤 CoreData fetched message files: \(message.files ?? [])")}// CoreData 확인
            
            let chattingModels = coreMessages.map { toChattingModel(from: $0) }
            chattingModels.forEach { model in print("📤 ChattingModel files: \(model.files)")} // 변환 후 확인
            return chattingModels
        } catch {
            print("채팅 메시지 가져오기 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchChatRoom(roomID: String) -> ChattingRoomModel? {
        if let coreDataChatRoom = fetchChatRoom(by: roomID) {
            return toChattingRoomModel(chatRoom: coreDataChatRoom)
        }
        return nil
    }
    // MARK: - 특정 채팅방 가져오기
    private func fetchChatRoom(by roomID: String) -> CoreDataChatRoom? {
        let request: NSFetchRequest<CoreDataChatRoom> = CoreDataChatRoom.fetchRequest()
        request.predicate = NSPredicate(format: "roomID == %@", roomID)
        do {
            if let chatRoom = try managedObjectContext.fetch(request).first {
                
                
                return chatRoom
            } else {
                print("roomID가 \(roomID)인 채팅방을 찾을 수 없습니다.")
                return nil
            }
        } catch {
            print("채팅방 가져오기 실패: \(error.localizedDescription)")
            return nil
        }
    }
}

extension ChatRepository {
    
    // MARK: - 채팅방 존재 여부 확인
    private func isChatRoomExist(roomID: String) -> Bool {
        return fetchChatRoom(by: roomID) != nil
    }
    
    
    // MARK: - CoreData 저장
    private func saveContext() {
        do {
//            print("💾 저장 전 상태:")
            print("Inserted Objects:", managedObjectContext.insertedObjects)
            print("Updated Objects:", managedObjectContext.updatedObjects)
            print("Deleted Objects:", managedObjectContext.deletedObjects)
            
            try managedObjectContext.save()
//            print("✅ 저장 성공")
        } catch {
            managedObjectContext.rollback()
//            print("❌ 저장 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Transformable 객체 생성
    private func createCoreUser(userModel: UserModel) -> CoreUser {
        return CoreUser(userID: userModel.userID,
                        nick: userModel.nick,
                        profileImage: userModel.profileImage)
    }
    
    private func createLastChat(lastChatModel: LastChatModel) -> CoreLastChat {
        return CoreLastChat(chatID: lastChatModel.chatID,
                            type: lastChatModel.type.rawValue,
                            lastChat: lastChatModel.lastChat,
                            sender: createCoreUser(userModel: lastChatModel.sender))
    }
    
    // MARK: - CoreDataChatRoom -> ChattingRoomModel 변환
    private func toChattingRoomModel(chatRoom: CoreDataChatRoom) -> ChattingRoomModel? {
        guard let roomID = chatRoom.roomID,
              let createdAt = chatRoom.createdAt,
              let updatedAt = chatRoom.updatedAt else {
            print("필수 데이터 누락: roomID, createdAt, updatedAt 확인 필요")
            return nil
        }
        
        let meModel = UserModel(
            userID: chatRoom.me?.userID ?? "",
            nick: chatRoom.me?.nick ?? "",
            profileImage: chatRoom.me?.profileImage ?? ""
        )
        
        let otherModel = UserModel(
            userID: chatRoom.other?.userID ?? "",
            nick: chatRoom.other?.nick ?? "",
            profileImage: chatRoom.other?.profileImage ?? ""
        )
        
        let lastChatModel = chatRoom.lastChat.flatMap { lastChat in
            return LastChatModel(
                type: MessageType(rawValue: lastChat.type ?? "text") ?? .text,
                chatID: lastChat.chatID ?? "",
                lastChat: lastChat.lastChat ?? "",
                sender: UserModel(
                    userID: lastChat.sender?.userID ?? "",
                    nick: lastChat.sender?.nick ?? "",
                    profileImage: lastChat.sender?.profileImage ?? ""
                )
            )
            
        }
        
        return ChattingRoomModel(
            roomID: roomID,
            createAt: createdAt,
            updatedAt: updatedAt,
            me: meModel,
            otherUser: otherModel,
            lastChat: lastChatModel
        )
    }
    
    // MARK: - ChattingRoomModel -> CoreDataChatRoom 변환
    private func toCoreDataChatRoom(from chatRoomData: ChattingRoomModel) -> CoreDataChatRoom {
        let newChatRoom = CoreDataChatRoom(context: managedObjectContext)
//        print("🗒️", chatRoomData)
        newChatRoom.roomID = chatRoomData.roomID
        print(newChatRoom.roomID ?? "")
        newChatRoom.createdAt = chatRoomData.createAt
        newChatRoom.updatedAt = chatRoomData.updatedAt
        newChatRoom.me = createCoreUser(userModel: chatRoomData.me)
        newChatRoom.other = createCoreUser(userModel: chatRoomData.otherUser)
        newChatRoom.lastChat = chatRoomData.lastChat.map { createLastChat(lastChatModel: $0) }
//        print(newChatRoom,"🗒️")
        dump(newChatRoom)
        return newChatRoom
    }
    
    func toChattingModel(from coreMessage: CoreDataChatMessage) -> ChattingModel {
        return ChattingModel(
            chatID: coreMessage.chatID ?? "",
            roomID: coreMessage.roomID ?? "",
            type: MessageType(rawValue: coreMessage.type ?? "text") ?? .text,
            content: coreMessage.content ?? "",
            createdAt: coreMessage.createdAt ?? "",
            sender: UserModel(
                userID: coreMessage.sender?.userID ?? "",
                nick: coreMessage.sender?.nick ?? "",
                profileImage: coreMessage.sender?.profileImage ?? ""
            ),
            files: coreMessage.files ?? []
        )
    }
    
    //삭제
    func deleteChatRoom(by roomID: String) {
        let request: NSFetchRequest<CoreDataChatRoom> = CoreDataChatRoom.fetchRequest()
        request.predicate = NSPredicate(format: "roomID == %@", roomID)
        
        do {
            if let chatRoom = try managedObjectContext.fetch(request).first {
                managedObjectContext.delete(chatRoom) // 채팅방 삭제
                saveContext()
                print("roomID가 \(roomID)인 채팅방이 성공적으로 삭제되었습니다.")
            } else {
                print("roomID가 \(roomID)인 채팅방을 찾을 수 없습니다.")
            }
        } catch {
            print("채팅방 삭제 실패: \(error.localizedDescription)")
        }
    }
    
    func deleteAllChatRooms() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CoreDataChatRoom.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedObjectContext.execute(batchDeleteRequest)
            saveContext() // 필요에 따라 Context 저장
//            print("모든 채팅방이 삭제되었습니다.")
        } catch {
            print("모든 채팅방 삭제 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    
    private func convertStringToDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}
