//
//  CommonImageView.swift
//  DogWalk
//
//  Created by 박성민 on 11/11/24.
//

import SwiftUI

struct asImageView: View {
    let imageRepository = ImageRepository()
    let url: String
    let saveType: ImageSaveType
    @State private var image: Image
    init(url: String, image: Image = .asTestImage, saveType: ImageSaveType = .cache) {
        self.url = url
        self.image = image //플레이스 홀더
        self.saveType = saveType
    }
    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .task {
                do {
                    let result = try await imageRepository.getImageData(url: url, saveType: saveType)
                    if let imageData = result, let uiImage = UIImage(data: imageData) {
                        image = Image(uiImage: uiImage)
                    } else {
                        image = Image.asTestImage
                    }
                } catch {
                    print("이미지 처리 오류 발생!!!")
                }
            }
    }
}

