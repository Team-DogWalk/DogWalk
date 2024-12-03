//
//  CoreUserModel.swift
//  DogWalk
//
//  Created by 김윤우 on 11/21/24.
//

import Foundation

public class CoreUserModel: NSObject, Codable {
    public static var supportsSecureCoding: Bool = true

    public var userID: String?
    public var nick: String?
    public var profileImage: String?
  
    public init(userID: String? = nil, nick: String? = nil, profileImage: String? = nil) {
        self.userID = userID
        self.nick = nick
        self.profileImage = profileImage
    }

    // Coding 프로토콜 구현: encode 메서드
    public func encode(with coder: NSCoder) {
        coder.encode(userID, forKey: "userID")
        coder.encode(nick, forKey: "nick")
        coder.encode(profileImage, forKey: "profileImage")
    }

    // NSCoder를 통한 초기화
    public required init?(coder: NSCoder) {
        self.userID = coder.decodeObject(forKey: "userID") as? String
        self.nick = coder.decodeObject(forKey: "nick") as? String
        self.profileImage = coder.decodeObject(forKey: "profileImage") as? String
    }
}
