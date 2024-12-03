//
//  CommunityIntent.swift
//  DogWalk
//
//  Created by 박성민 on 11/12/24.
//

import Foundation

protocol CommunityIntentProtocol {
    func onAppear() //뷰 뜰때
    func changeArea(area: CheckPostType)
    func selectCategory(category: CommunityCategoryType)
    func postPageNation()
}

final class CommunityIntent {
    private weak var state: CommunityActionProtocol?
    private var useCase: CommunityUseCase
    init(state: CommunityActionProtocol, useCase: CommunityUseCase) {
        self.state = state
        self.useCase = useCase
    }
}

extension CommunityIntent: CommunityIntentProtocol {
    func onAppear() { //뷰 로드 시
        state?.changeContentState(state: .loading)
        Task {
            do {
                let result = try await useCase.getPosts(isPaging: false)
                state?.getPosts(result)
                state?.changeContentState(state: .content)
            } catch {
                state?.changeContentState(state: .error)
            }
        }
    }
    func postPageNation() { //포스트 페이지네이션
        state?.changeContentState(state: .loading)
        Task {
            do {
                let result = try await useCase.getPosts(isPaging: true)
                state?.postPageNation(result)
                state?.changeContentState(state: .content)
            } catch {
                state?.changeContentState(state: .error)
            }
        }
    }
    func changeArea(area: CheckPostType) { //위치 vs 전체
        state?.changeContentState(state: .loading)
        Task {
            do {
                let result = try await useCase.changePostType(postType: area)
                state?.getPosts(result)
                state?.changeContentState(state: .content)
                state?.changeArea(area)
            } catch {
                state?.changeContentState(state: .error)
            }
        }
        
        
    }
    func selectCategory(category: CommunityCategoryType) { //카테고리 변경
        state?.changeContentState(state: .loading)
        Task {
            do {
                let result = try await useCase.changeCategory(category: category)
                state?.getPosts(result)
                state?.changeContentState(state: .content)
                state?.changeSelectCategory(category)
            } catch {
                if let communityErr = error as? CommunityError {
                    state?.changeContentState(state: .content)
                } else {
                    state?.changeContentState(state: .error)
                }
            }
        }
    }
    
}
