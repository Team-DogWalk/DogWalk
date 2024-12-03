//
//  FileDTO.swift
//  DogWalk
//
//  Created by 박성민 on 11/21/24.
//

import Foundation

struct FileDTO: Decodable {
    let files: [String]
}
extension FileDTO {
    func toDomain() -> FileModel {
        return FileModel(url: self.files)
    }
}
struct FileModel {
    let url: [String]
}
