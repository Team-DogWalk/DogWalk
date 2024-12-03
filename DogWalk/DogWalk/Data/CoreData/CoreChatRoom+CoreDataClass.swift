//
//  CoreChatRoom+CoreDataClass.swift
//  DogWalk
//
//  Created by 김윤우 on 11/21/24.
//
//

import Foundation
import CoreData

@objc(CoreChatRoom)
public class CoreChatRoom: NSManagedObject {
    public class func fetchRequest() -> NSFetchRequest<CoreChatRoom> {
        return NSFetchRequest<CoreChatRoom>(entityName: "CoreChatRoom")
    }
    
    @NSManaged public var otherProfileImage: String?
    @NSManaged public var otherNick: String?
    @NSManaged public var ohterUserID: String?
    @NSManaged public var meProfileImage: String?
    @NSManaged public var meNick: String?
    @NSManaged public var meUserID: String?
    @NSManaged public var createdAt: String?
    @NSManaged public var updateAt: String?
    @NSManaged public var roomID: String?
    @NSManaged public var type: String?
    @NSManaged public var chatID: String?
    @NSManaged @objc public var lastChat: CoreLastChat?
    @NSManaged @objc public var sender: CoreUserModel?
    @NSManaged @objc public var messages: [CoreChatMessage]?
    
}

