//
//  CommunityDetailIntent.swift
//  DogWalk
//
//  Created by 박성민 on 11/19/24.
//

import Foundation

protocol CommunityDetailIntentProtocol {
    func onAppear()
    func toggleisLike(isLike: Bool)
    func sendContent(text: String)
}

final class CommunityDetailIntent {
    private weak var state: CommunityDetailActionProtocol?
    private var useCase: CommunityDetailUseCase
    init(state: CommunityDetailActionProtocol, useCase: CommunityDetailUseCase) {
        self.state = state
        self.useCase = useCase
    }
}

extension CommunityDetailIntent: CommunityDetailIntentProtocol {
    func onAppear() {
        state?.changeState(state: .loading)
        Task {
            do {
                let result = try await useCase.getDetailPost()
                state?.getPost(isLike: result.0, post: result.1)
                state?.changeState(state: .content)
            } catch {
                state?.changeState(state: .error)
            }
        }
    }
    func toggleisLike(isLike: Bool) {
        Task {
            do {
                let result = try await useCase.changePostLike()
                state?.getLike(isLike: result)
                state?.changeState(state: .content)
            } catch {
                state?.changeState(state: .error)
            }
        }
    }
    func sendContent(text: String) {
        Task {
            do {
                let result = try await useCase.addContent(content: text)
                state?.getContent(content: result)
                state?.changeState(state: .content)
            } catch {
                state?.changeState(state: .error)
            }
        }
    }
    
}
