//
//  CommunityUseCase.swift
//  DogWalk
//
//  Created by 박성민 on 11/12/24.
//

import Foundation
import Combine

enum CheckPostType {
    case userLocation
    case all
    
    var title: String {
        switch self {
        case .userLocation:
            return UserManager.shared.roadAddress
        case .all:
            return "전국"
        }
    }
}
enum CommunityError: Error {
    case sameCategory
}
protocol CommunityUseCase {
    func changePostType(postType: CheckPostType) async throws -> [PostModel]
    func changeCategory(category: CommunityCategoryType) async throws -> [PostModel]
    func getPosts(isPaging: Bool) async throws -> [PostModel]
}
// MARK: - 실제 앱에 사용할 UseCase
final class DefaultCommunityUseCase: CommunityUseCase {
    private let network = NetworkManager()
    private let userManager = UserManager.shared
    private var checkPostType: CheckPostType
    private var category: CommunityCategoryType
    init(checkPostType: CheckPostType, category: CommunityCategoryType) {
        self.checkPostType = checkPostType
        self.category = category
    }
    //postType 변경 시
    func changePostType(postType: CheckPostType) async throws -> [PostModel] {
        self.checkPostType = postType
        return try await self.getPosts(isPaging: false)
    }
    //카테고리 변경 시
    
    func changeCategory(category: CommunityCategoryType) async throws -> [PostModel] {
        // TODO: 빈값 줄 시 -[UIImageView _invalidateImageLayouts] must be called on the main queue라고 노란 경고창 뜸 ㅠ
        if category == self.category {
            throw CommunityError.sameCategory
        } else {
            self.category = category
            return try await self.getPosts(isPaging: false)
        }
        
    }
    //실제 네트워크 처리
    func getPosts(isPaging: Bool) async throws -> [PostModel] {
        do {
            let all = CommunityCategoryType.allCases.filter { $0 != .all }.map { $0.rawValue }
            let categorys = self.category == .all ? all : [self.category.rawValue]
            switch checkPostType {
            case .all:
                let result = try await network.fetchPosts(category: categorys, isPaging: isPaging)
                return result
                
            case .userLocation:
                let future = try await network.fetchAreaPosts(category: category, lon: String(userManager.lon), lat: String(userManager.lat))
                return future
            }
        } catch {
            guard let  err = error as? NetworkError else { throw error}
            throw err
        }
    }
}

// MARK: - 테스트를 위한 useCase
final class MockCommunityUseCase: CommunityUseCase {
    private let mockData = [
        PostModel(
            postID: "1",
            created: "2024-11-13",
            category: .all,
            title: "Used iPhone for Sale",
            price: 300,
            content: "Selling my iPhone in good condition.",
            creator: UserModel(userID: "", nick: "감자", profileImage: ""),
            files: ["iphone.jpg"],
            likes: ["user2", "user3"],
            views: 120,
            hashTags: ["#iphone", "#forsale"],
            comments: [],
            geolocation: GeolocationModel(lat: 37.7749, lon: -122.4194),
            distance: 5.0
        ),
        PostModel(
            postID: "2",
            created: "2024-11-12",
            category: .free,
            title: "Community Cleanup Event",
            price: 0,
            content: "Join us for a community cleanup event this weekend.",
            creator: UserModel(userID: "", nick: "감자", profileImage: ""),
            files: ["cleanup.jpg"],
            likes: ["user1", "user3", "user4"],
            views: 80,
            hashTags: ["#community", "#cleanup"],
            comments: [],
            geolocation: GeolocationModel(lat: 37.7749, lon: -122.4194),
            distance: 2.5
        ),
        PostModel(
            postID: "3",
            created: "2024-11-10",
            category: .question,
            title: "Looking for a Freelance Developer",
            price: 0,
            content: "Need a developer for a short-term project.",
            creator: UserModel(userID: "", nick: "감자", profileImage: ""),
            files: ["job.jpg"],
            likes: ["user4", "user5"],
            views: 150,
            hashTags: ["#freelance", "#developer"],
            comments: [],
            geolocation: GeolocationModel(lat: 34.0522, lon: -118.2437),
            distance: 15.0
        ),
    ]
    func changePostType(postType: CheckPostType) async throws -> [PostModel] {
        return self.mockData
    }
    
    func changeCategory(category: CommunityCategoryType) async throws -> [PostModel] {
        return self.mockData
    }
    
    func getPosts(isPaging: Bool) async throws -> [PostModel] {
        return self.mockData
    }
    
    
}
