//
//  APITarget.swift
//  DogWalk
//
//  Created by junehee on 11/1/24.
//

import Foundation

enum APITarget {
    case auth(AuthTarget)
    case user(UserTarget)
    case post(PostTarget)
    case chat(ChatTarget)
}

extension APITarget: TargetType {
    var baseURL: String {
        switch self {
        case .auth(let authTarget): authTarget.baseURL
        case .user(let userTarget): userTarget.baseURL
        case .post(let postTarget): postTarget.baseURL
        case .chat(let chatTarget): chatTarget.baseURL
        }
    }
    
    var path: String {
        switch self {
        case .auth(let authTarget): authTarget.path
        case .user(let userTarget): userTarget.path
        case .post(let postTarget): postTarget.path
        case .chat(let chatTarget): chatTarget.path
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .auth(let authTarget): authTarget.method
        case .user(let userTarget): userTarget.method
        case .post(let postTarget): postTarget.method
        case .chat(let chatTarget): chatTarget.method
        }
    }
    
    var header: [String : String] {
        switch self {
        case .auth(let authTarget): authTarget.header
        case .user(let userTarget): userTarget.header
        case .post(let postTarget): postTarget.header
        case .chat(let chatTarget): chatTarget.header
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .auth(let authTarget): authTarget.query
        case .user(let userTarget): userTarget.query
        case .post(let postTarget): postTarget.query
        case .chat(let chatTarget): chatTarget.query
        }
    }
    
    var body: Data? {
        switch self {
        case .auth(let authTarget): authTarget.body
        case .user(let userTarget): userTarget.body
        case .post(let postTarget): postTarget.body
        case .chat(let chatTarget): chatTarget.body
        }
    }
    
    // var boundary: String {
    //     <#code#>
    // }
}
