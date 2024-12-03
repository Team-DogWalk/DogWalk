//
//  CoreChatMessageTransformer.swift
//  DogWalk
//
//  Created by 김윤우 on 11/21/24.
//

import Foundation

//MARK: NSKeyedArchiver, PropertyListDecoder 디,인코딩 어떤 코더로 할지 고민
@objc(CoreChatMessageTransformer)
class CoreChatMessageTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? CoreChatMessage else { return nil }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true)
            return data
        } catch {
            print("CoreChatMessageTransformer 인코딩 실패: \(error)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let allowedClasses: [AnyClass] = [
                CoreChatMessage.self,
                NSString.self,  // 속성 타입이 NSString일 경우
                NSNumber.self,  // 숫자 타입 (필요 시)
                NSData.self     // 파일 데이터 포함 가능
            ]
            let message = try NSKeyedUnarchiver.unarchivedObject(ofClasses: allowedClasses, from: data) as? CoreChatMessage
            return message
        } catch {
            print("CoreChatMessageTransformer 디코딩 실패: \(error)")
            return nil
        }
    }
    
    static func register() {
        let name = NSValueTransformerName(rawValue: "CoreChatMessageTransformer")
        ValueTransformer.setValueTransformer(CoreChatMessageTransformer(), forName: name)
    }
}

@objc(CoreLastChatTransformer)
class CoreLastChatTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? CoreLastChat else { return nil }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true)
            return data
        } catch {
            print("CoreLastChatTransformer 인코딩 실패: \(error)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let allowedClasses: [AnyClass] = [
                CoreLastChat.self,
                CoreUser.self,     // CoreUser 추가
                NSString.self,     // 문자열 속성
                NSArray.self,     // 파일 배열 속성
                NSData.self,       // 데이터 속성
                NSNumber.self      // 숫자 속성
            ]
            let lastChat = try NSKeyedUnarchiver.unarchivedObject(ofClasses: allowedClasses, from: data) as? CoreLastChat
            return lastChat
        } catch {
            print("CoreLastChatTransformer 디코딩 실패: \(error)")
            return nil
        }
    }
    
    static func register() {
        let name = NSValueTransformerName(rawValue: "CoreLastChatTransformer")
        ValueTransformer.setValueTransformer(CoreLastChatTransformer(), forName: name)
    }
}

@objc(CoreUserTransformer)
class CoreUserTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? CoreUser else { return nil }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true)
            return data
        } catch {
            print("CoreUserTransformer 인코딩 실패: \(error)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let allowedClasses: [AnyClass] = [
                CoreUser.self,   // 디코딩 대상 클래스
                NSString.self,   // 속성 타입이 NSString일 경우
                NSData.self      // 파일 데이터 포함 가능
            ]
            let user = try NSKeyedUnarchiver.unarchivedObject(ofClasses: allowedClasses, from: data) as? CoreUser
            return user
        } catch {
            print("CoreUserTransformer 디코딩 실패: \(error)")
            return nil
        }
    }
    
    static func register() {
        let name = NSValueTransformerName(rawValue: "CoreUserTransformer")
        ValueTransformer.setValueTransformer(CoreUserTransformer(), forName: name)
    }
}
@objc(StringArrayTransformer)
class StringArrayTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? [String] else { return nil }
        do {
            let data = try JSONEncoder().encode(value)
            return data
        } catch {
            print("StringArrayTransformer 인코딩 실패: \(error)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let array = try JSONDecoder().decode([String].self, from: data)
            return array
        } catch {
            print("StringArrayTransformer 디코딩 실패: \(error)")
            return nil
        }
    }
    
    static func register() {
        let name = NSValueTransformerName(rawValue: "StringArrayTransformer")
        ValueTransformer.setValueTransformer(StringArrayTransformer(), forName: name)
    }
}
