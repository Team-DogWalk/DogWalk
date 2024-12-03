//
//  MapUseCase.swift
//  DogWalk
//
//  Created by 박성민 on 11/21/24.
//

import Foundation

protocol MapUseCase {
    func getPost(lat: Double, lon: Double) async throws -> ([PostModel]) //위치에 따른 포스트 조회
}

final class DefaultMapUseCase: MapUseCase {
    private let network = NetworkManager()

    func getPost(lat: Double, lon: Double) async throws -> ([PostModel]) {
        do {
            let future = try await network.fetchAreaPosts(category: .walkCertification, lon: String(Float(lon)), lat: String(Float(lat)))
            return future
        } catch {
            guard let  err = error as? NetworkError else { throw error}
            throw err
        }
    }
}
