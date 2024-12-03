//
//  CommonLoadingView.swift
//  DogWalk
//
//  Created by 박성민 on 11/19/24.
//

import SwiftUI

struct CommonLoadingView: View {
    var body: some View {
        VStack {
            Text("로딩 중...")
            ProgressView()
        }
    }
}

