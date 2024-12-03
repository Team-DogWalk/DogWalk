//
//  WalkResultIntent.swift
//  DogWalk
//
//  Created by 박성민 on 11/6/24.
//

import Foundation

protocol WalkResultIntentProtocol {
    func startPostingButtonTap()
    func dismissButtonTap()
    func calculateCalories()
}

final class WalkResultIntent {
    private weak var state: WalkResultActionProtocol?
    
    init(state: WalkResultActionProtocol) {
        self.state = state
    }
    
}


extension WalkResultIntent: WalkResultIntentProtocol {
    func startPostingButtonTap() {
        print("게시글 작성버튼 눌림")
    }
    
    func dismissButtonTap() {
        print("뒤로가기 버튼 클릭")
    }
    
    func calculateCalories() {
        state?.calculateCalories()
    }
    
}
