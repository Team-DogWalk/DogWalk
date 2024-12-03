//
//  CoretLastChat.swift
//  DogWalk
//
//  Created by 김윤우 on 11/21/24.
//

import Foundation

@objc(CoreLastChat)
public class CoreLastChat: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true

    public var type: String?
    public var chatID: String?
    public var lastChat: String?
    public var sender: CoreUser?
    public var files: [String] = []

    public init(chatID: String? = nil, type: String? = nil, lastChat: String? = nil, sender: CoreUser? = nil, files: [String] = []) {
        self.chatID = chatID
        self.type = type
        self.lastChat = lastChat
        self.sender = sender
        self.files = files
    }

    public func encode(with coder: NSCoder) {
        coder.encode(chatID, forKey: "chatID")
        coder.encode(type, forKey: "type")
        coder.encode(lastChat, forKey: "lastChat")
        coder.encode(sender, forKey: "sender")
        coder.encode(files, forKey: "files")
    }

    public required init?(coder: NSCoder) {
        self.chatID = coder.decodeObject(forKey: "chatID") as? String
        self.type = coder.decodeObject(forKey: "type") as? String
        self.lastChat = coder.decodeObject(forKey: "lastChat") as? String
        self.sender = coder.decodeObject(forKey: "sender") as? CoreUser
        self.files = coder.decodeObject(forKey: "files") as? [String] ?? []
    }
}
