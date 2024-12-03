//
//  CoreUser.swift
//  DogWalk
//
//  Created by 김윤우 on 11/21/24.
//

import Foundation
import CoreData

@objc(CoreUser)
public class CoreUser: NSObject, NSSecureCoding {
    // NSSecureCoding을 지원하도록 설정
    public static var supportsSecureCoding: Bool {
        return true
    }

    public var userID: String?
    public var nick: String?
    public var profileImage: String?

    // 기본 초기화 메서드
    public init(userID: String? = nil, nick: String? = nil, profileImage: String? = nil) {
        self.userID = userID
        self.nick = nick
        self.profileImage = profileImage
    }

    // NSCoder를 사용한 초기화
    public required init?(coder: NSCoder) {
        self.userID = coder.decodeObject(forKey: "userID") as? String
        self.nick = coder.decodeObject(forKey: "nick") as? String
        self.profileImage = coder.decodeObject(forKey: "profileImage") as? String
    }

    // NSSecureCoding 프로토콜 구현: encode 메서드
    public func encode(with coder: NSCoder) {
        coder.encode(userID, forKey: "userID")
        coder.encode(nick, forKey: "nick")
        coder.encode(profileImage, forKey: "profileImage")
    }
}
