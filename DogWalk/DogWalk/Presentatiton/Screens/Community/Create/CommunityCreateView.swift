//
//  CommunityCreateView.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import SwiftUI

struct CommunityCreateView: View {
    @State private var category: CommunityCategoryType = .all
    @State private var isPresent = false    // 카테고리 선택 BottomSheet Open Control
    @State private var titleText = ""       // 게시물 제목
    @State private var priceText = ""       // 게시물 가격
    @State private var contentText = ""     // 게시물 내용
    
    private let width = UIScreen.main.bounds.width
    
    var body: some View {
        ScrollView(.vertical) {
            categoryButtonView()
            titleFieldView()
            priceFieldView()
            contentFieldView()
            photoFieldView()
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("게시물 작성")
        submitButtonView()
    }
    
    // 카테고리 선택 버튼 -> BottomSheet Open
    private func categoryButtonView() -> some View {
        Button(action: {
            isPresent.toggle()
        }, label: {
            // 카테고리
            HStack {
                Text(category == .all ? "카테고리 선택" : category.rawValue)
                Spacer()
                Image.asDownChevron
            }
            .padding(.horizontal)
            .sheet(isPresented: $isPresent) {
                CommunityCategorySelectedView()
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.fraction(0.5)])
            }
        })
        .foregroundStyle(Color.primaryGreen)
        .padding(.top)
    }
    
    // 제목
    private func titleFieldView() -> some View {
        VStack(alignment: .leading) {
            Text("제목")
                .font(.pretendardBold16)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primaryBlack.opacity(0.1), lineWidth: 1)
                TextField(text: $titleText) {
                    Rectangle()
                        .fill(.clear)
                        .border(Color.primaryBlack.opacity(0.5), width: 1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .overlay {
                            Text("제목을 입력해 주세요.")
                                .font(.pretendardRegular14)
                                .frame(maxWidth: .infinity)
                        }
                }
                .font(.pretendardRegular16)
                .padding(.leading, 10)
            }
            .frame(minHeight: 40)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    // 가격
    private func priceFieldView() -> some View {
        VStack(alignment: .leading) {
            Text("판매가격")
                .font(.pretendardBold16)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primaryBlack.opacity(0.1), lineWidth: 1)
                TextField(text: $priceText) {
                    Rectangle()
                        .fill(.clear)
                        .border(Color.primaryBlack.opacity(0.5), width: 1)
                        .frame(maxWidth: .infinity)
                        .overlay {
                            Text("₩")
                                .font(.pretendardRegular16)
                                .frame(maxWidth: .infinity)
                        }
                }
                .font(.pretendardRegular16)
                .padding(.leading, 10)
            }
            .frame(minHeight: 40)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    // 내용
    private func contentFieldView() -> some View {
        VStack(alignment: .leading) {
            Text("내용")
                .font(.pretendardBold16)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primaryBlack.opacity(0.1), lineWidth: 1)
                TextEditor(text: $contentText)
                    .font(.pretendardRegular14)
                    .overlay(alignment: .topLeading) {
                        Text("내용을 입력해 주세요.\n최대 1000자 입력, 사진 최대 10장 업로드")
                            .foregroundStyle(contentText.isEmpty ? .gray : .clear)
                            .font(.pretendardRegular16)
                            .padding(10)
                    }
                    .font(.pretendardRegular14)
                    .border(Color.primaryBlack.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))
            }
            .frame(height: 250)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    // 사진
    private func photoFieldView() -> some View {
        HStack {
            // 사진 추가 버튼
            Button(action: {
                print("사진 추가 버튼 클릭")
            }, label: {
                ZStack {
                    Rectangle()
                        .frame(width: 70, height: 70)
                        .tint(Color.gray.opacity(0.2))
                    Image.asPlus
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.primaryWhite)
                }
                
            })
            // 사진 스크롤뷰
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<5) { item in
                        ZStack(alignment: .topTrailing) {
                            Image.asTestImage
                                .resizable()
                                .frame(width: 70, height: 70)
                                .aspectRatio(contentMode: .fit)
                            Button(action: {
                                print("선택 사진 삭제")
                            }, label: {
                                Circle()
                                    .foregroundStyle(Color.primaryBlack)
                                    .frame(width: 18, height: 18)
                                    .overlay {
                                        Image.asXmark
                                            .resizable()
                                            .frame(width: 10, height: 10)
                                            .tint(.primaryWhite)
                                    }
                            })
                            .offset(x: 3, y: -6)
                        }
                        .frame(width: 70, height: 90)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .frame(height: 90)
        .padding(.horizontal)
    }
    
    // 저장 버튼
    private func submitButtonView() -> some View {
        VStack {
            CommonButton(width: width * 0.90, height: 50,
                         cornerradius: 20, backColor: Color.primaryLime,
                         text: "등록하기", textFont: .pretendardSemiBold14)
            .wrapToButton {
                print("버튼 클릭 시 게시물 등록")
            }
        }
        .frame(height: 70)
        .background(Color.primaryWhite)
    }
}

#Preview {
    CommunityCreateView()
}
