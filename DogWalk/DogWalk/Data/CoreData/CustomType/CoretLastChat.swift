//
//  CoretLastChat.swift
//  DogWalk
//
//  Created by 김윤우 on 11/21/24.
//

import Foundation

public class CoreLastChat: NSObject, Codable {
    // This allows CoreData to use the custom class in transformations.
    public static var supportsSecureCoding: Bool = true

    // Properties to be encoded/decoded
    public var type: String?
    public var chatID: String?
    public var lastChat: String?
    public var sender: CoreUserModel?  // Assuming UserModel is a Codable class

    // Custom initializer that takes optional parameters, with default values.
    public init(chatID: String? = nil, type: String? = nil, lastChat: String? = nil, sender: CoreUserModel? = nil) {
        self.chatID = chatID
        self.type = type
        self.lastChat = lastChat
        self.sender = sender
    }

    // Conformance to NSCoding for archiving (if needed)
    public func encode(with coder: NSCoder) {
        coder.encode(chatID, forKey: "chatID")
        coder.encode(type, forKey: "type")
        coder.encode(lastChat, forKey: "lastChat")
        coder.encode(sender, forKey: "sender")
    }

    // Decoding object properties from NSCoder (reversing encode)
    public required init?(coder: NSCoder) {
        self.chatID = coder.decodeObject(forKey: "chatID") as? String
        self.type = coder.decodeObject(forKey: "type") as? String
        self.lastChat = coder.decodeObject(forKey: "lastChat") as? String
        self.sender = coder.decodeObject(forKey: "sender") as? CoreUserModel
    }

    // Conformance to Codable for serialization (JSON, etc.)
    enum CodingKeys: String, CodingKey {
        case chatID, type, lastChat, sender
    }

    // Used when decoding the model from data (like JSON).
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(chatID, forKey: .chatID)
        try container.encode(type, forKey: .type)
        try container.encode(lastChat, forKey: .lastChat)
        try container.encode(sender, forKey: .sender)
    }

    // Decoding model from JSON or other data sources.
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        chatID = try container.decodeIfPresent(String.self, forKey: .chatID)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        lastChat = try container.decodeIfPresent(String.self, forKey: .lastChat)
        sender = try container.decodeIfPresent(CoreUserModel.self, forKey: .sender)
    }
}
