//
//  CoreChatMessageTransformer.swift
//  DogWalk
//
//  Created by 김윤우 on 11/21/24.
//

import Foundation

//class CoreChatMessageTransformer: ValueTransformer {
//    override func transformedValue(_ value: Any?) -> Any? {
//        guard let messages = value as? [CoreChatMessage] else { return nil }
//        
//        // CoreData의 지정되어 있지 않은 Custom(Transformable은 NsData형식으로 CoreData에 저장 후 사용할 때 Decoding)
//        // CoreChatMessage 배열을 NSData로 변환 (PropertyListEncoder 사용)
//        do {
//            let encoder = PropertyListEncoder()
//            let data = try encoder.encode(messages)
//            return data
//        } catch {
//            print("CoreChatMessageTransformer 인코딩 실패: \(error)")
//            return nil
//        }
//    }
//    
//    // NsData를 CoreChatMessage 배열로 복원
//    override func reverseTransformedValue(_ value: Any?) -> Any? {
//        guard let data = value as? Data else { return nil }
//        
//        do {
//            let decoder = PropertyListDecoder()
//            let messages = try decoder.decode([CoreChatMessage].self, from: data)
//            return messages
//        } catch {
//            print("CoreChatMessageTransformer 디코딩 실패: \(error)")
//        }
//        return nil
//    }
//    
//    // 변환기
//    static func register() {
//        let className = String(describing: CoreChatMessageTransformer.self)
//        let name = NSValueTransformerName(className)
//        let transformer = CoreChatMessageTransformer()
//        ValueTransformer.setValueTransformer(transformer, forName: name)
//    }
//}
class CoreChatMessageTransformer: ValueTransformer {
    // CoreChatMessage 변환
    override func transformedValue(_ value: Any?) -> Any? {
        guard let messages = value as? [CoreChatMessage] else { return nil }
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(messages)
            return data
        } catch {
            print("CoreChatMessageTransformer 인코딩 실패: \(error)")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let decoder = PropertyListDecoder()
            let messages = try decoder.decode([CoreChatMessage].self, from: data)
            return messages
        } catch {
            print("CoreChatMessageTransformer 디코딩 실패: \(error)")
        }
        return nil
    }

    // CoreLastChat 변환
    func transformedValueLastChat(_ value: Any?) -> Any? {
        guard let lastChat = value as? CoreLastChat else { return nil }
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(lastChat)
            return data
        } catch {
            print("CoreLastChat 인코딩 실패: \(error)")
            return nil
        }
    }

    func reverseTransformedValueLastChat(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let decoder = PropertyListDecoder()
            let lastChat = try decoder.decode(CoreLastChat.self, from: data)
            return lastChat
        } catch {
            print("CoreLastChat 디코딩 실패: \(error)")
        }
        return nil
    }

    // CoreUserModel 변환
    func transformedUserModel(_ value: Any?) -> Any? {
        guard let userModel = value as? CoreUserModel else { return nil }
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(userModel)
            return data
        } catch {
            print("CoreUserModel 인코딩 실패: \(error)")
            return nil
        }
    }

    func reverseTransformedUserModel(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let decoder = PropertyListDecoder()
            let userModel = try decoder.decode(CoreUserModel.self, from: data)
            return userModel
        } catch {
            print("CoreUserModel 디코딩 실패: \(error)")
        }
        return nil
    }
    
    // 변환기 등록 (static 메서드 사용)
    static func register() {
        let className = String(describing: CoreChatMessageTransformer.self)
        let name = NSValueTransformerName(className)
        let transformer = CoreChatMessageTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
