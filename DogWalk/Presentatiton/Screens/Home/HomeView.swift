//
//  HomeView.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import SwiftUI

struct HomeView: View {
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    var body: some View {
        NavigationView {
            ScrollView {
                ZStack {
                    Color.primaryGray
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: height/2)
                    VStack {
                        VStack(alignment: .leading) {
                            Text("산책 가방 어디써? 빨리 나가자")//prompt
                                .font(.pretendardSemiBold30)
                                .padding(.vertical,1)
                            VStack(alignment: .leading) {
                                Text("위치 · 문래동6가")//위치
                                    .padding(.vertical,1)
                                Text("날씨 · 흐림")//날씨
                            }
                            .font(.pretendardRegular17)
                            .foregroundColor(.gray)
                        }
                        .padding(10)
                        .frame(maxWidth: width*2/3, alignment: .topLeading)
                    }
                    .frame(maxWidth: .infinity, maxHeight: height/2, alignment: .topLeading)
                          
                    Image(.test)
                        .resizable()
                        .frame(width: 300, height: 300)
                        .frame(maxWidth: .infinity, maxHeight: height/2, alignment: .bottomTrailing)
                }
                .frame(height: height/2)
                
                HStack(spacing: 20) {
                    //버튼들
                    CommonButton(width: 170, height: 50, cornerradius: 20, backColor: .primaryGreen, text: "함께 산책하기  🐾", textFont: .pretendardSemiBold18)
                    CommonButton(width: 170, height: 50, cornerradius: 20, backColor: .primaryLime, text: "산책 인증하기", textFont: .pretendardSemiBold18, rightLogo: .asTestLogo, imageSize: 20)
                }
                .padding(.vertical,10)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(1..<10, id: \.self) {_ in
                            Image(.testAdCell)//광고 이미지
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .containerRelativeFrame(.horizontal)//컨테이너에 상대적인 크기를 지정
                        }
                    }
                }
                .scrollTargetBehavior(.paging)
                
                Text("인기 산책 인증")
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .font(.pretendardBold15)
                    .padding(.horizontal,20)
                    .padding(.vertical,5)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(1..<10, id: \.self) { _ in
                            Image(.test)
                                .resizable()
                                .frame(width: 100, height: 130)
                                .clipShape(.rect(cornerRadius: 15))
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("도그워크")
                        .font(.bagelfat28)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    CommonProfile(image: .asTestProfile, size: 44)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
