//
//  HomeIntent.swift
//  DogWalk
//
//  Created by 김윤우 on 11/12/24.
//

import Foundation

protocol HomeIntentProtocol {
    func profileButtonTap()
    func goToDogWalkTap()
    func goToAddPostButtonTap()
    func fetchPostList() async
    func resetProfileButtonState()
}

final class HomeIntent {
    private weak var state: HomeIntentActionProtocol?

    init(state: HomeIntentActionProtocol) {
        self.state = state
    }
}

extension HomeIntent: HomeIntentProtocol {
    func fetchPostList() async {
        guard state?.isHomeViewFirstInitState() == true else { return }
        await state?.getPostList()
        state?.changeHomeViewInitState()
    }
    
    func profileButtonTap() {
        state?.profileButtonTap()
    }
    
    func resetProfileButtonState() {
        state?.isResetProfileButtonState()
       }
    
    func goToDogWalkTap() {
        print("산책하기 탭으로 이동")
    }
    
    func goToAddPostButtonTap() {
        print("산책 인증 게시물 작성")
    }
}
