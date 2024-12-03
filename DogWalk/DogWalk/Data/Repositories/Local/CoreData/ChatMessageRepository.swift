//
//  ChatMessageRepository.swift
//  DogWalk
//
//  Created by 김윤우 on 11/3/24.
//

import CoreData

final class ChatMessageRepository {
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    // Create
    func addChatMessage(to chatRoom: ChatRoom,
                    content: String,
                    senderID: String,
                    senderNick: String,
                    senderProfileImage: String?,
                    photoFiles: [String]?) {
        
        let newMessage = ChatMessage(context: viewContext)
        newMessage.roomID = "멋쟁이 윤우"
        newMessage.content = content
        newMessage.senderUserID = senderID
        newMessage.senderNick = senderNick
        newMessage.senderProfileImage = senderProfileImage
        newMessage.photoFiles = photoFiles
        newMessage.timeStamp = Date()
        
        chatRoom.addToMessages(newMessage)
        saveContext()
    }
    
    // Read
    func fetchMessages(for chatRoom: ChatRoom) -> [ChatMessage] {
        let request: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()
        request.predicate = NSPredicate(format: "room == %@", chatRoom)
        request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch messages: \(error)")
            return []
        }
    }
    
    // Read - 단일 메시지 조회
    func fetchMessage(withID messageID: NSManagedObjectID) -> ChatMessage? {
        do {
            return try viewContext.existingObject(with: messageID) as? ChatMessage
        } catch {
            print("Failed to fetch message: \(error)")
            return nil
        }
    }
    
    // Update
    func updateMessage(_ message: ChatMessage,
                      newContent: String? = nil,
                      newSenderProfileImage: String? = nil) {
        if let content = newContent {
            message.content = content
        }
        if let profileImage = newSenderProfileImage {
            message.senderProfileImage = profileImage
        }
        message.timeStamp = Date()
        saveContext()
    }
    
    // Delete
    func deleteMessage(_ message: ChatMessage) {
        viewContext.delete(message)
        saveContext()
    }
    
    // Delete - 특정 채팅방의 모든 메시지 삭제
    func deleteAllMessages(in chatRoom: ChatRoom) {
        let messages = fetchMessages(for: chatRoom)
        messages.forEach { viewContext.delete($0) }
        saveContext()
    }

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
