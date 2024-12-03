//
//  CommonButton.swift
//  DogWalk
//
//  Created by 박성민 on 10/30/24.
//

import SwiftUI

// 디폴트로 이미지는 nil입니다.
// 버튼에 이미지 사용 시 init 시 이미지 넣어주세요.
// 이미지 사이즈도 커스텀 가능합니다~
struct CommonButton: View {
    let width: CGFloat // 가로
    let height: CGFloat // 세로
    let cornerradius: CGFloat
    let backColor: Color // 버튼 색
    let text: String
    let textFont: Font
    let textColor: Color
    let leftLogo: Image?
    let rightLogo: Image?
    let imageSize: CGFloat // 이미지 사이즈 설정
    
    init(width: CGFloat, height: CGFloat, cornerradius: CGFloat, backColor: Color, text: String, textFont: Font, textColor: Color = .primaryBlack, leftLogo: Image? = nil, rightLogo: Image? = nil, imageSize: CGFloat = 30) {
        self.width = width
        self.height = height
        self.cornerradius = cornerradius
        self.backColor = backColor
        self.text = text
        self.textFont = textFont
        self.textColor = textColor
        self.imageSize = imageSize
        self.leftLogo = leftLogo
        self.rightLogo = rightLogo
        
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerradius)
            .fill(backColor)
            .frame(width: width, height: height)
            .overlay(
                HStack {
                    leftLogo?
                        .resizable()
                        .frame(width: imageSize, height: imageSize)
                    Text(text)
                        .font(textFont)
                        .foregroundStyle(textColor)
                        .lineLimit(1)
                    rightLogo?
                        .resizable()
                        .frame(width: imageSize, height: imageSize)
                } //:HSTACK
            )
            
    }
}

#Preview {
    CommonButton(width: 200, height: 44, cornerradius: 5, backColor: .primaryGreen, text: "산책 시작하기", textFont: .bagelfat18, leftLogo: .asHeart, rightLogo: .asTestLogo, imageSize: 30)
}
