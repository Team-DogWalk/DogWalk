//
//  CommunityDetailUseCase.swift
//  DogWalk
//
//  Created by 박성민 on 11/19/24.
//

import Foundation

protocol CommunityDetailUseCase {
    func getDetailPost() async throws -> (Bool, PostModel) //포스터 조회
    func changePostLike() async throws -> Bool //좋아요 등록
    func addContent(content: String) async throws -> CommentModel //댓글 작성
}

final class DefaultCommunityDetailUseCase {
    private let network = NetworkManager()
    private let userManager = UserManager.shared
    private var id: String
    private var isLike: Bool = false
    init(id: String) {
        self.id = id
    }
}

extension DefaultCommunityDetailUseCase: CommunityDetailUseCase {
    func getDetailPost() async throws -> (Bool, PostModel) {
        do {
            await network.addViews(id: id) //조회수 증가 시키기!
            let future = try await network.fetchDetailPost(id: self.id)
            let post = try await future.value
            let isLike = post.likes.contains(userManager.userID)
            self.isLike = isLike
            return (isLike, post)
        } catch {
            guard let  err = error as? NetworkError else { throw error}
            throw err
        }
    }
    func changePostLike() async throws -> Bool {
        let toggleLike = self.isLike ? false : true
        do {
            let future = try await network.postLike(id: self.id, status: toggleLike)
            let resultLike = try await future.value
            self.isLike = resultLike.likeStatus
            return self.isLike
        } catch {
            guard let  err = error as? NetworkError else { throw error}
            throw err
        }
    }
    func addContent(content: String) async throws -> CommentModel {
        let future = try await network.addContent(id: self.id, content: content)
        let result = try await future.value
        return result
    }
}
