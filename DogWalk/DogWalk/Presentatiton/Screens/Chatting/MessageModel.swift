//
//  MessageModel.swift
//  DogWalk
//
//  Created by 박성민 on 11/2/24.
//

// import SwiftUI
// 
// struct MessageModel: Identifiable {
//     enum MessageType: String {
//         case text
//         case image
//     }
//     
//     //let room: UUID = UUID() //방 id
//     let id: UUID = UUID() //채팅 하나 id
//     let userID: String // 상대방 id
//     let type: MessageType
//     let content: String
//     var date: Date?
//     var showProfile: Bool
//     var image: UIImage = .test
// }
// // 채팅 3 id: A, B, C
// 
// @Observable
// class Message: Equatable {
//     static func == (lhs: Message, rhs: Message) -> Bool {
//         return false
//     }
//     
//     var modles: [MessageModel] = [
//         MessageModel(userID: "나", type: .text, content: "안녕!", date: Date(), showProfile: true),
//         MessageModel(userID: "다른유저", type: .text, content: "오늘 정말 기분이 좋아요!", date: Date(), showProfile: false),
//         MessageModel(userID: "나", type: .text, content: "이 사진 정말 멋지지 않나요?", date: Date(), showProfile: true),
//         MessageModel(userID: "다른유저", type: .text, content: "새로 산 카메라로 찍어봤어요.", date: Date(), showProfile: false),
//         MessageModel(userID: "나", type: .text, content: "와, 멋져요!", date: Date(), showProfile: true),
//         MessageModel(userID: "다른유저", type: .text, content: "산책 가는 거 어때요?", date: Date(), showProfile: false),
//         MessageModel(userID: "나", type: .text, content: "공원에서 만날까요?", date: Date(), showProfile: true),
//         MessageModel(userID: "다른유저", type: .image, content: "이거 보세요!", date: Date(), showProfile: false),
//         MessageModel(userID: "나", type: .text, content: "정말 멋지다!", date: Date(), showProfile: true),
//         MessageModel(userID: "다른유저", type: .text, content: "모두가 즐거운 시간을 보낼 수 있도록 좋은 장소를 추천해 드릴게요.", date: Date(), showProfile: false),
//         MessageModel(userID: "나", type: .text, content: "오늘 날씨가 너무 좋아서 밖에 나가 산책을 하고 싶어요.", date: Date(), showProfile: true),
//         MessageModel(userID: "다른유저", type: .text, content: "오케이! 저도 준비할게요.", date: Date(), showProfile: false),
//         MessageModel(userID: "나", type: .text, content: "가자!", date: Date(), showProfile: true),
//         MessageModel(userID: "다른유저", type: .text, content: "새 카메라를 테스트하면서 정말 멋진 장면을 몇 장 찍었어요!", date: Date(), showProfile: false),
//         MessageModel(userID: "나", type: .text, content: "좋아요!", date: Date(), showProfile: true),
//         MessageModel(userID: "다른유저", type: .text, content: "이곳에 오면 정말 멋진 풍경을 볼 수 있을 거예요. 꼭 와봐요!", date: Date(), showProfile: false),
//         MessageModel(userID: "나", type: .text, content: "네!", date: Date(), showProfile: true),
//         MessageModel(userID: "다른유저", type: .text, content: "가까운 공원에서요.", date: Date(), showProfile: false),
//         MessageModel(userID: "나", type: .text, content: "완전 좋아요! 모두 곧 만나요!", date: Date(), showProfile: true),
//         MessageModel(userID: "다른유저", type: .image, content: "어제 밤에 찍은 사진인데 정말 멋진 순간을 포착했어요.", date: Date(), showProfile: false),
//         MessageModel(userID: "나", type: .image, content: "어제 밤에 찍은 사진인데 정말 멋진 순간을 포착했어요.", date: Date(), showProfile: false)
//     ]
//     
//     func addMessage(text: String) {
//         let random = Bool.random()
//         self.modles.append(MessageModel(userID: random ? "나" : "다른유저", type: .text, content: text, date: Date(), showProfile: random))
//     }
//     
//     func addImage(image: UIImage) {
//         let random = Bool.random()
//         self.modles.append(MessageModel(userID: "나", type: .image, content: "", date: Date(), showProfile: true, image: image))
//     }
// }
