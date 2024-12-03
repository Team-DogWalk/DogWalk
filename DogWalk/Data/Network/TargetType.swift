//
//  TargetType.swift
//  DogWalk
//
//  Created by junehee on 11/2/24.
//

import Foundation

protocol TargetType {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var header: [String: String] { get }
    var query: [URLQueryItem]? { get }
    var body: Data? { get }
    // var boundary: String { get }   // multipart-form?
}

extension TargetType {
    func asURLRequest() throws -> URLRequest? {
        let base = try baseURL.asURL()
        
        var components = URLComponents(url: base.appending(path: path),
                                       resolvingAgainstBaseURL: false)
        components?.queryItems = query  // query 사용하는 경우
        
        guard let URL = components?.url else { throw URLError(.badURL) }
        var request = URLRequest(url: URL,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 10)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = header
        request.httpBody = body
        return request
    }
}
