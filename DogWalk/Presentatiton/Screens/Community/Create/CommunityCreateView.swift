//
//  CommunityCreateView.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import SwiftUI
import PhotosUI

struct CommunityCreateView: View {
    @State private var category: CommunityCategoryType = .all
    @State private var isPresent = false    // 카테고리 선택 BottomSheet Open Control
    @State private var titleText = ""       // 게시물 제목
    @State private var priceText = ""       // 게시물 가격
    @State private var contentText = ""     // 게시물 내용
    @State var selectedItems: [PhotosPickerItem] = []
    @State private var alertShow = false   //얼럿
    @State private var errAlertShow = false // 오류 얼럿
    private let width = UIScreen.main.bounds.width
    @EnvironmentObject var coordinator: MainCoordinator
    var body: some View {
        ScrollView(.vertical) {
            categoryButtonView()
            titleFieldView()
            priceFieldView()
            contentFieldView()
                .padding(.bottom)
            photoFieldView()
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("게시물 작성")
        .alert("게시글 작성완료!", isPresented: $alertShow) {
            Button("확인") {
                coordinator.pop()
            }
        }
        .alert("게시글 작성 오류 발생!", isPresented: $errAlertShow) {
            Button("확인") {}
        }
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
                categoryButtomSheet()
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.fraction(0.35)])
            }
        })
        .foregroundStyle(Color.primaryGreen)
        .padding(.top)
    }
    private func categoryButtomSheet() -> some View {
        ForEach(CommunityCategoryType.allCases.filter {$0 != .all && $0 != .walkCertification}, id: \.self) { topic in
            Button(action: {
                category = topic
                isPresent.toggle()
            }, label: {
                CommonButton(width: width * 0.8, height: 50,
                             cornerradius: 20, backColor: Color.primaryLime,
                             text: topic.rawValue, textFont: .pretendardSemiBold16)

            })
        }
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
            PhotosPicker(
                  selection: $selectedItems,
                  maxSelectionCount: 1,
                  matching: .images
                ) {
                    ZStack {
                        Rectangle()
                            .frame(width: 100, height: 100)
                            .tint(Color.gray.opacity(0.2))
                        Image.asPlus
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.primaryWhite)
                    }
                }
            // 사진 스크롤뷰
            ScrollView(.horizontal) {
                HStack {
                    ForEach(selectedItems, id:\.hashValue) { item in
                        ZStack(alignment: .topTrailing) {
                            PhotosPickerItemTransferable(item: item)
                            Button(action: {
                                selectedItems.removeAll()
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
                        .frame(width: 100, height: 120)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .frame(height: 120)
        .padding(.horizontal)
    }
    
    // 저장 버튼
    private func submitButtonView() -> some View {
        VStack {
            CommonButton(width: width * 0.90, height: 50,
                         cornerradius: 20, backColor: Color.primaryLime,
                         text: "등록하기", textFont: .pretendardSemiBold14)
            .wrapToButton {
                let network = NetworkManager()
                guard let image = selectedItems.first else  { return }
                image.loadTransferable(type: Data.self) { result in
                    switch result {
                    case .success(let data):
                        Task {
                            let result = try await network.uploadImagePost(imageData: data ?? Data())
                            
                            let postBody = PostBody(category: self.category.rawValue, title: self.titleText, price: Int(self.priceText) ?? 0, content: self.contentText, files: result.url, longitude: UserManager.shared.lon, latitude: UserManager.shared.lat)
                            
                            let _ = try await network.writePost(body: postBody)
                            print("게시글 작성완료!!!!!!!!")
                            alertShow.toggle()
                        }
                        
                    case .failure(let failure):
                        print("이미지 변환 실패!")
                        errAlertShow.toggle()
                    }
                }
                
            }
        }
        .frame(height: 70)
        .background(Color.primaryWhite)
    }
}

#Preview {
    CommunityCreateView()
}

struct PhotosPickerItemTransferable: View {
    let item: PhotosPickerItem

    @State private var imageData: Data? = nil
    
    var body: some View {
        Group {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 100, height: 100)
            } else {
                Rectangle().fill(Color.gray.opacity(0.2)) // Placeholder if the image is not loaded
            }
        }
        .onAppear {
            // Load image data when the view appears
            loadImage()
        }
    }
    
    private func loadImage() {
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                imageData = data
            case .failure:
                print("Failed to load image")
            }
        }
    }
}
