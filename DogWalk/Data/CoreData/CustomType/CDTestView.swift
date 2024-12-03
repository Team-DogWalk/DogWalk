////
////  CDTestView.swift
////  DogWalk
////
////  Created by 김윤우 on 11/23/24.
////
//
//import SwiftUI
//
//struct ChatTestView: View {
//    private let repository = ChatRepository.shared
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Button("채팅방 생성") {
//                createChatRoom()
//            }
//            
//            Button("특정 채팅방 가져오기") {
//                fetchSpecificChatRoom()
//            }
//            
//            Button("모든 채팅방 가져오기") {
//                fetchAllChatRooms()
//            }
//            
//            Button("특정 채팅방 업데이트") {
//                updateChatRoomMetadata()
//            }
//            
//            Button("채팅 메시지 생성") {
//                createChatMessage()
//            }
//            
//            Button("특정 채팅방의 모든 메시지 가져오기") {
//                fetchMessages()
//            }
//            
//            Button("특정 채팅방 메시지 업데이트") {
//                updateChatRoomMessages()
//            }
//            Button("채팅방 삭제") {
//                            deleteChatRoom()
//                        }
//        }
//        .padding()
//    }
//    
//    // MARK: - 채팅방 생성
//    private func createChatRoom() {
//        let chatRoom = ChattingRoomModel(
//            roomID: "room123",
//            createAt: "\(Date())",
//            updatedAt: "\(Date())",
//            me: UserModel(userID: "me123", nick: "MyNick", profileImage: "myImage.png"),
//            otherUser: UserModel(userID: "other123", nick: "OtherNick", profileImage: "otherImage.png"),
//            lastChat: nil
//        )
//        repository.createChatRoom(chatRoomData: chatRoom)
//        print("채팅방 생성 완료: \(chatRoom)")
//    }
//    
//    // MARK: - 특정 채팅방 가져오기
//    private func fetchSpecificChatRoom() {
//        if let chatRoom = repository.fetchChatRoom(roomID: "room123") {
//            print("특정 채팅방 가져오기: \(chatRoom)")
//        } else {
//            print("채팅방을 찾을 수 없습니다.")
//        }
//    }
//    
//    // MARK: - 모든 채팅방 가져오기
//    private func fetchAllChatRooms() {
//        if let chatRooms = repository.fetchAllChatRoom() {
//            print("모든 채팅방 가져오기: \(chatRooms)")
//        } else {
//            print("채팅방 목록이 비어 있습니다.")
//        }
//    }
//    
//    // MARK: - 특정 채팅방 메타데이터 업데이트
//    private func updateChatRoomMetadata() {
//        let updatedChatRoom = ChattingRoomModel(
//            roomID: "room123",
//            createAt: "\(Date())",
//            updatedAt: "\(Date())",
//            me: UserModel(userID: "me123", nick: "UpdatedNick", profileImage: "updatedImage.png"),
//            otherUser: UserModel(userID: "other123", nick: "UpdatedOtherNick", profileImage: "updatedOtherImage.png"),
//            lastChat: LastChatModel(
//                type: .text,
//                chatID: "last123",
//                lastChat: "Updated last chat content",
//                sender: UserModel(userID: "me123", nick: "MyNick", profileImage: "myImage.png")
//            )
//        )
//        repository.createChatRoom(chatRoomData: updatedChatRoom)
//        print("채팅방 메타데이터 업데이트 완료")
//    }
//    
//    // MARK: - 채팅 메시지 생성
//    private func createChatMessage() {
//        let chatMessage = ChattingModel(
//            chatID: "msg123",
//            roomID: "room123",
//            type: .text,
//            content: "Hello, this is a test message!",
//            createdAt: "\(Date())",
//            sender: UserModel(userID: "me123", nick: "MyNick", profileImage: "myImage.png"),
//            files: ["file1.png", "file2.png"]
//        )
//        repository.createChatMessage(chatRoomID: "room123", messageData: chatMessage)
//        print("채팅 메시지 생성 완료")
//    }
//    
//    // MARK: - 특정 채팅방의 모든 메시지 가져오기
//    private func fetchMessages() {
//        let messages = repository.fetchMessages(for: "room123")
//        print("특정 채팅방의 모든 메시지: \(messages)")
//    }
//    
//    // MARK: - 특정 채팅방의 메시지 업데이트
//    private func updateChatRoomMessages() {
//        let newMessages = [
//            ChattingModel(
//                chatID: "msg1",
//                roomID: "room123",
//                type: .text,
//                content: "첫 번째 메시지",
//                createdAt: "\(Date())",
//                sender: UserModel(
//                    userID: "sender123",
//                    nick: "SenderNick",
//                    profileImage: "senderImage.png"
//                ),
//                files: []
//            ),
//            ChattingModel(
//                chatID: "msg2",
//                roomID: "room123",
//                type: .text,
//                content: "두 번째 메시지",
//                createdAt: "\(Date())",
//                sender: UserModel(
//                    userID: "sender124",
//                    nick: "AnotherSender",
//                    profileImage: "anotherImage.png"
//                ),
//                files: []
//            )
//        ]
//        
//        let coreMessages = newMessages.compactMap {
//            repository.createChatMessage(chatRoomID: "room123", messageData: $0)
//        }
//        
//        repository.updateChatRoom(chatRoomID: "room123", with: coreMessages)
//        print("특정 채팅방 메시지 업데이트 완료")
//    }
//    
//    private func deleteChatRoom() {
//           repository.deleteChatRoom(by: "room123")
//       }
//}
