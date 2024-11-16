//
//  TestLoginAccount.swift
//  DogWalk
//
//  Created by junehee on 11/11/24.
//

import Foundation

enum TestLoginAccount: String {
    case common
    case junehee
    case jack
    case hue
    case den
    case bran
    case ron
    case wind
    
    var idString: String {
        switch self {
        case .common:
            return "dogwalk1@test.com"
        case .junehee:
            return "junehee@dogwalk.com"
        case .jack:
            return "jack@dogwalk.com"
        case .hue:
            return "hue@dogwalk.com"
        case .den:
            return "den@dogwalk.com"
        case .bran:
            return "bran@dogwalk.com"
        case .ron:
            return "ron@dogwalk.com"
        case .wind:
            return "wind@dogwalk.com"
        }
    }
    
    var pwString: String {
        switch self {
        case .common:
            return "1234!@"
        default:
            return self.rawValue
        }
    }
}
