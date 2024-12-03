//
//  UpdateUserBody.swift
//  DogWalk
//
//  Created by 박성민 on 11/24/24.
//

import Foundation

// 프로필 수정 요청 (Request)
struct UpdateUserBody: Encodable {
    let nick: String
    let info1: String
    let info2: String
    let info3: String
    let info4: String
    let info5: String
}

func createMultipartUserBody(parameters: UpdateUserBody, boundary: String) -> Data {
    let crlf = "\r\n"
    var body = Data()
    // UpdateUserBody를 Key-Value로 변환
    let parametersDict: [String: String] = [
        "nick": parameters.nick,
        "info1": parameters.info1,
        "info2": parameters.info2,
        "info3": parameters.info3,
        "info4": parameters.info4,
        "info5": parameters.info5
    ]

    for (key, value) in parametersDict {
        body.append("--\(boundary)\(crlf)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(key)\"\(crlf)\(crlf)".data(using: .utf8)!)
        body.append("\(value)\(crlf)".data(using: .utf8)!)
    }

    // Boundary 종료
    body.append("--\(boundary)--\(crlf)".data(using: .utf8)!)

    return body
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
