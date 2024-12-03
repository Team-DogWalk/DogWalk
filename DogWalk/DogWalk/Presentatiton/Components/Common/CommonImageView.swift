//
//  CommonImageView.swift
//  DogWalk
//
//  Created by 박성민 on 11/11/24.
//

import SwiftUI

struct asImageView: View {
    let imageCacheManager = ImageCacheManager()
    let url: String
    @State private var image: Image
    init(url: String, image: Image = .asTestImage) {
        self.url = url
        self.image = image //플레이스 홀더
    }
    var body: some View {
        image
            .resizable()
            .task {
                let result = await imageCacheManager.getImage(url)
                image = Image(uiImage: result)
            }
    }
}

