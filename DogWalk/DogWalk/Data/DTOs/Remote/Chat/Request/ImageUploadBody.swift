//
//  ImageUploadBody.swift
//  DogWalk
//
//  Created by 박성민 on 11/21/24.
//

import Foundation

struct ImageUploadBody {
   let boundary: String = UUID().uuidString
   let files: [Data]
}
