//
//  CommonTitleView.swift
//  DogWalk
//
//  Created by junehee on 11/11/24.
//

import SwiftUI

struct CommonTitleView: View {
    let title: String
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        HStack {
            Text("MeongTalk")
                .font(.bagelfat28)
            Spacer()
        }
        .padding(.bottom, 10)
    }
}
