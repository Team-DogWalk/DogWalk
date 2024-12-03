//
//  WalkResultCreateView.swift
//  DogWalk
//
//  Created by 박성민 on 11/21/24.
//

import SwiftUI
final class DefaultWalkResultCreateUseCase {
    let network = NetworkManager()
    func createPost(title: String, content: String, image: Data, time: Int, distance: Double, calorie: Double) async throws {
        let realDistance = distance.rounded()/1000
        do {
            let imageURL = try await network.uploadImagePost(imageData: image)
            let sumContent = content + "\n\n\n" + "산책 시간: \(Int(time).formatted())s\n산책 거리: \(realDistance)km\n칼로리: \(Int(calorie).formatted())Kcal"
            let Postbody = PostBody(category: CommunityCategoryType.walkCertification.rawValue, title: title, price: 0, content: sumContent, files: imageURL.url, longitude: UserManager.shared.lon, latitude: UserManager.shared.lat)
            try await network.writePost(body: Postbody)
            print("포스터 작성 완료!!")
        } catch {
            print(error)
        }
        
    }
}
struct WalkResultCreateView: View {
    @State private var category: CommunityCategoryType = .walkCertification
    @State private var titleText = ""       // 게시물 제목
    @State private var contentText = ""     // 게시물 내용
    @State private var alertShow = false   //얼럿
    @State private var errAlertShow = false // 오류 얼럿
    @EnvironmentObject var coordinator: MainCoordinator
    //int, double,double
    var walkTime: Int
    var walkDistance: Double
    var walkCalorie: Double
    var walkImage: UIImage
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
    private let usecase = DefaultWalkResultCreateUseCase()
    
    var body: some View {
        ScrollView(.vertical) {
            CommonButton(width: width * 0.9, height: height * 0.05, cornerradius: 5, backColor: .primaryLime, text: category.rawValue, textFont: .pretendardBold18)
            titleFieldView()
            contentFieldView()
            walkResultView()
                .padding(.top)
        }
        .navigationTitle("게시물 작성")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Action
                    Task {
                        do {
                            try await usecase.createPost(title: titleText, content: contentText, image: walkImage.jpegData(compressionQuality: 0.5) ?? Data(), time: walkTime, distance: walkDistance, calorie: walkCalorie)
                            self.alertShow.toggle()
                        } catch {
                            print("미완 ㅠ")
                        }
                    }
                } label: {
                    Text("등록하기")
                }
            }
        }
        .alert("게시글 작성완료!", isPresented: $alertShow) {
            Button("확인") {
                coordinator.pop()
            }
        }
        .alert("게시글 작성 오류 발생!", isPresented: $errAlertShow) {
            Button("확인") {}
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
}
// MARK: - 산책 정보
private extension WalkResultCreateView {
    func walkResultView() -> some View {
        ZStack {
            Rectangle()
                .frame(width: width * 0.9, height: height * 0.365)
                .foregroundStyle(Color.primaryLime)
                .overlay (
                    VStack {
                        infos()
                            .padding(.top)
                        Image(uiImage: walkImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
        } //:VSTACK
    }
    //정보들
    func infos() -> some View {
        HStack(spacing: 35) {
            info(top: "산책 시간", mid: "\(walkTime/60)", bottom: "min")
            
            Rectangle()
                .fill(Color.primaryGray)
                .frame(width: 1, height: 60)
            
            info(top: "거리", mid: "\(walkDistance.rounded()/1000)", bottom: "km")
            
            Rectangle()
                .fill(Color.primaryGray)
                .frame(width: 1, height: 60)
            
            info(top: "칼로리", mid: "\(Int(walkCalorie).formatted())", bottom: "kcal")
            
            
        } //:HSTACK
    }
    //각각의 정보
    func info(top: String, mid: String, bottom: String) -> some View {
        VStack(spacing: 10) {
            Text(top)
                .font(.pretendardBold12)
                .foregroundStyle(Color.primaryBlack)
            Text(mid)
                .font(.pretendardSemiBold20)
                .foregroundStyle(Color.primaryBlack)
            Text(bottom)
                .font(.pretendardRegular14)
                .foregroundStyle(Color.primaryBlack)
        } //:VSTACK
    }
}
//#Preview {
////    WalkResultCreateView(walkTime: 30, walkDistance: 60.0, walkCalorie: 23.1)
//}
