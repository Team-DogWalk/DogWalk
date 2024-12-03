//
//  CommonProfile.swift
//  DogWalk
//
//  Created by 박성민 on 10/30/24.
//

import SwiftUI

struct CommonProfile: View {
    let imageURL: String
    let size: CGFloat
    let backColor: Color
    init(imageURL: String, size: CGFloat, backColor: Color = .primaryWhite) {
        self.imageURL = imageURL
        self.size = size
        self.backColor = backColor
    }
    
    var body: some View {
        asImageView(url: imageURL, image: .asTestProfile)
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .cornerRadius(size/2)
            .overlay(
                RoundedRectangle(cornerRadius: size/2)
                    .stroke(Color.primaryBlack.opacity(0.5), lineWidth: 1)
            )
            
            
    }
}

#Preview {
    CommonProfile(imageURL: "", size: 100, backColor: .red)
}
