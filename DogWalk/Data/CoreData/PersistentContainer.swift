//
//  PersistentContainer.swift
//  DogWalk
//
//  Created by 김윤우 on 11/21/24.
//

import CoreData

class PersistentContainer {
    static let shared = PersistentContainer()
    let container: NSPersistentContainer

    private init() {
        // Core Data 모델 파일의 URL 명시
        guard let modelURL = Bundle.main.url(forResource: "CoreDataModel", withExtension: "momd") else {
            fatalError("Failed to locate Core Data model")
        }
        // NSManagedObjectModel 생성
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load Core Data model")
        }
        // NSPersistentContainer 초기화
        container = NSPersistentContainer(name: "CoreDataModel", managedObjectModel: managedObjectModel)
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }
}
