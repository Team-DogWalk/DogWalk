//
//  CoreDataManager.swift
//  DogWalk
//
//  Created by 김윤우 on 11/21/24.
//

import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "CoreChatRoom") // Core Data 모델 이름
        
        // Storage 경로 고정
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                  .appendingPathComponent("CoreChatRoom.dogwalk")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        CoreChatMessageTransformer.register()
    }

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
