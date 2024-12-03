//
//  CoreChatMessage.swift
//  DogWalk
//
//  Created by 김윤우 on 11/21/24.
//

import Foundation
@objc(CoreChatMessage)
public class CoreChatMessage: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true

    public var chatID: String?
    public var roomID: String?
    public var type: String?
    public var files: [String]?
    public var message: String?
    public var senderUserID: String?
    public var senderUserNick: String?
    public var senderProfileImage: String?
    public var createdAt: String?

    public init(chatID: String? = nil, roomID: String? = nil, type: String? = nil, files: [String]? = nil, message: String? = nil, senderUserID: String? = nil, senderUserNick: String? = nil, profileImage: String? = nil, createdAt: String? = nil) {
        self.chatID = chatID
        self.roomID = roomID
        self.type = type
        self.files = files
        self.message = message
        self.senderUserID = senderUserID
        self.senderUserNick = senderUserNick
        self.senderProfileImage = profileImage
        self.createdAt = createdAt
    }

    public func encode(with coder: NSCoder) {
        coder.encode(chatID, forKey: "chatID")
        coder.encode(roomID, forKey: "roomID")
        coder.encode(type, forKey: "type")
        coder.encode(files, forKey: "files")
        coder.encode(message, forKey: "message")
        coder.encode(senderUserID, forKey: "senderUserID")
        coder.encode(senderUserNick, forKey: "senderUserNick")
        coder.encode(senderProfileImage, forKey: "profileImage")
        coder.encode(createdAt, forKey: "createdAt")
    }

    public required init?(coder: NSCoder) {
        self.chatID = coder.decodeObject(forKey: "chatID") as? String
        self.roomID = coder.decodeObject(forKey: "roomID") as? String
        self.type = coder.decodeObject(forKey: "type") as? String
        self.files = coder.decodeObject(forKey: "files") as? [String]
        self.message = coder.decodeObject(forKey: "message") as? String
        self.senderUserID = coder.decodeObject(forKey: "senderUserID") as? String
        self.senderUserNick = coder.decodeObject(forKey: "senderUserNick") as? String
        self.senderProfileImage = coder.decodeObject(forKey: "profileImage") as? String
        self.createdAt = coder.decodeObject(forKey: "createdAt") as? String
    }
}
