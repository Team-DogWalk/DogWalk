//
//  PostRepository.swift
//  DogWalk
//
//  Created by 박성민 on 12/2/24.
//

import Foundation
protocol PostRepository {
    func fetchPosts(category: [String]?, isPaging: Bool) async throws -> [PostModel] // 전체 포스터 조회
    func fetchAreaPosts(category: CommunityCategoryType, lon: String, lat: String) async throws -> [PostModel] // 위치 포스터 조회
    func fetchDetailPost(id: String) async throws -> PostModel // 한개 포스트 조회
    func addContent(id: String, content: String) async throws -> CommentModel // 댓글 작성
    func postLike(id: String, status: Bool) async throws -> LikePostModel // 좋아요
    func writePost(post: PostInput, image: Data?) async throws // 게시글 작성
}
final class DefaultPostRepository: PostRepository {
    private let network = NetworkManager()
    private var page = ""
    // 전체 포스터 조회
    func fetchPosts(category: [String]?, isPaging: Bool) async throws -> [PostModel] {
        if (isPaging == false) {
            self.page = ""
        }
        if self.page == "0" { return []}
        let query = GetPostQuery(next: self.page, limit: "20", category: category)
        //let future = try await request(target: .post(.getPosts(query: query)), of: PostResponseDTO.self)
        let decodedResponse = try await network.requestDTO(target: .post(.getPosts(query: query)), of: PostResponseDTO.self)
        self.page = decodedResponse.next_cursor
        return decodedResponse.data.map{$0.toDomain()}
    }
    // 위치 포스터 조회
    func fetchAreaPosts(category: CommunityCategoryType, lon: String, lat: String) async throws -> [PostModel] {
        // 1. 기본 URL 설정
        guard var urlComponents = URLComponents(string: APIKey.baseURL + "/posts/geolocation") else {
            throw NetworkError.InvalidURL
        }
        // 2. 쿼리 항목 설정
        var queryItems = [
            URLQueryItem(name: "latitude", value: lat), // 위도
            URLQueryItem(name: "longitude", value: lon), // 경도
            URLQueryItem(name: "maxDistance", value: "1500") // 거리
        ]
        // 3. 카테고리 추가 (all은 제외)
        if category != .all {
            queryItems.append(URLQueryItem(name: "category", value: category.rawValue))
        }
        // 4. 쿼리 항목을 URLComponents에 추가
            urlComponents.queryItems = queryItems
        // 5. URL 생성 및 출력
        guard let url = urlComponents.url else { throw NetworkError.InvalidURL }
        // 6. 요청 준비
        var request = URLRequest(url: url)
        request.addValue(APIKey.appID, forHTTPHeaderField: BaseHeader.productId.rawValue)
        request.addValue(UserManager.shared.acess, forHTTPHeaderField: BaseHeader.authorization.rawValue)
        request.addValue(APIKey.key, forHTTPHeaderField: BaseHeader.sesacKey.rawValue)
        // 7. 데이터 요청 및 디코딩
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200 else {
            throw NetworkError.InvalidResponse
        }
        do {
            let decodedResponse = try JSONDecoder().decode(GeolocationPostResponseDTO.self, from: data)
            //dump(decodedResponse.data.map {$0.toDomain()})
            return decodedResponse.data.map {$0.toDomain()}
        } catch {
            print("Decoding Error: \(error)")
            throw NetworkError.DecodingError
        }
    }
    // 한개 포스트 조회
    func fetchDetailPost(id: String) async throws -> PostModel {
        let future = try await network.requestDTO(target: .post(.getPostsDetail(postID: id)), of: PostDTO.self)
        try await self.addViews(id: id) //조회수 증가!
        return future.toDomain()
    }
    // 댓글 작성
    func addContent(id: String, content: String) async throws -> CommentModel {
        let future = try await network.requestDTO(target: .post(.addContent(postID: id, body: CommentBody(content: content))), of: CommentDTO.self)
        return future.toDomain()
    }
    // 좋아요
    func postLike(id: String, status: Bool) async throws -> LikePostModel {
        let body = LikePostBody(like_status: status)
        let future = try await network.requestDTO(target: .post(.postLike(postID: id, body: body)), of: LikePostDTO.self)
        return future.toDomain()
    }
    // 게시글 작성
    func writePost(post: PostInput, image: Data?) async throws {
        let body: PostBody
        if let image {
            let imageURL = try await uploadImagePost(imageData: image)
            body = PostBody(category: post.category, title: post.title, price: post.price, content: post.content, files: imageURL.url, longitude: post.longitude, latitude: post.latitude)
            let _ = try await self.uploadPost(body: body)
        } else {
            body = PostBody(category: post.category, title: post.title, price: post.price, content: post.content, files: [], longitude: post.longitude, latitude: post.latitude)
            let _ = try await self.uploadPost(body: body)
        }
    }
}

private extension DefaultPostRepository {
    // 조회수 증가
    func addViews(id: String) async throws {
        let body = LikePostBody(like_status: true)
        _ = try await network.requestDTO(target: .post(.postView(postID: id, body: body)), of: LikePostDTO.self)
    }
    //파일 업로드
    func uploadImagePost(imageData: Data) async throws -> FileModel {
        let future = try await network.requestDTO(target: .post(.files(body: ImageUploadBody(files: [imageData]))), of: FileDTO.self)
        return future.toDomain()
    }
    //글 게시글
    func uploadPost(body: PostBody) async throws {
        let _ = try await network.requestDTO(target:.post(.post(body: body)), of: PostDTO.self)
    }
}
