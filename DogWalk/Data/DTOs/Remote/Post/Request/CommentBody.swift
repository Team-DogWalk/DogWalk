//
//  CommentBody.swift
//  DogWalk
//
//  Created by 박성민 on 11/19/24.
//

import Foundation

struct CommentBody: Encodable {
    let content: String
}

func asMultipartFileDatas(for boundary: String, key: String, values: [Data], filename: String) -> Data {
   let crlf = "\r\n"
   let dataSet = NSMutableData()
   values.forEach {
      dataSet.append("--\(boundary)\(crlf)".data(using: .utf8)!)
      dataSet.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\(crlf)".data(using: .utf8)!)
      dataSet.append("Content-Type: image/png\(crlf)\(crlf)".data(using: .utf8)!)
      dataSet.append($0)
      dataSet.append("\(crlf)".data(using: .utf8)!)
   }
   dataSet.append("--\(boundary)--\(crlf)".data(using: .utf8)!)
         
   return dataSet as Data
}

