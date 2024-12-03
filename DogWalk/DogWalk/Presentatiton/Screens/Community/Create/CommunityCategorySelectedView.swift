//
//  CommunityTopicSelectedView.swift
//  DogWalk
//
//  Created by junehee on 10/31/24.
//

import SwiftUI

struct CommunityCategorySelectedView: View {
    private let count = CommunityCategoryType.allCases.count
    private let width = UIScreen.main.bounds.width
    
    var body: some View {
        ForEach(CommunityCategoryType.allCases, id: \.self) { topic in
            Button(action: {
                print("선택한 카테괴리: ", topic.rawValue)
            }, label: {
                CommonButton(width: width * 0.8, height: 50,
                             cornerradius: 20, backColor: Color.primaryLime,
                             text: topic.rawValue, textFont: .pretendardSemiBold16)

            })
        }
    }
}

#Preview {
    CommunityCategorySelectedView()
}
