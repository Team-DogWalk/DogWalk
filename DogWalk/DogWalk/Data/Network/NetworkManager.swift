//
//  NetworkManager.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import Foundation
import Combine

protocol Requestable {
    func request<T: Decodable>(target: APITarget, of type: T.Type) async throws -> Future<T, NetworkError>      // Future 반환
    func requestDTO<T: Decodable>(target: APITarget, of type: T.Type) async throws -> T                         // DTO 반환
}

protocol SessionDatable {
    /**
     `public func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)? = nil) async throws -> (Data, URLResponse)`
     원래는 위와 같이 delegate를 받는 메서드로, task가 끝난 후 callback을 통해 delegate에게 전달하지만
     우리 프로젝트는 async-await를 통해 비동기 작업을 수행하기 때문에 메서드에 deleate를 삭제합니다!
     */
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// URLSession에 SessionDatable 프로토콜을 채택해주기 위한 익스텐션
extension URLSession: SessionDatable { }

// 네트워크 호출 매니저
final class NetworkManager: Requestable {
    private var page: String = "" // 페이지네이션
    private let session: SessionDatable
    private var cancellables = Set<AnyCancellable>()
    private var coreData = ChatRepository.shared
    init(session: SessionDatable = URLSession.shared) {
        self.session = session
    }
    
    func request<T>(target: APITarget, of type: T.Type) async throws -> Future<T, NetworkError> where T: Decodable {
        let retryHandler = NetworkRetryHandler()
        
        return Future { promise in
            Task {
                // 재귀 호출을 위한 apiCall 내부 함수 정의
                func apiCall(isRefresh: Bool = false) async {
                    do {
                        print("1️⃣ URLRequest 생성 시작")
                        var request = try target.asURLRequest()
                        // 토큰 갱신 후에는 Request Header를 다시 가져와야 하므로 URLRequest 재생성
                        if isRefresh {
                            do {
                                request = try target.asURLRequest()
                            } catch {
                                print("🚨 URLRequest 생성 실패: \(error)")
                                promise(.failure(.InvalidRequest))
                            }
                        }
                        
                        guard let request = request else {
                            print("🚨 리퀘스트 생성 실패")
                            promise(.failure(.InvalidRequest))
                            return
                        }
                        print("✨ URLRequest 생성 성공")
                        print("2️⃣ 네트워크 요청 시작")
                        let (data, response) = try await self.session.data(for: request)
                        print("3️⃣ 네트워크 응답 받음")
                        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                            // 응답은 왔지만 상태코드가 200이 아닐 때
                            print("🚨 유효하지 않은 응답 (StatusCode: \(httpResponse.statusCode))")
                            let error = NetworkError(rawValue: httpResponse.statusCode) ?? .InvalidResponse
                            // 상태코드 419일 때 토큰 갱신 처리
                            if error == .ExpiredAccessToken || error == .InvalidToken {
                                if await self.refreshToken() {
                                    // 토큰 갱신 성공했을 때 기존 호출 재시도
                                    await apiCall(isRefresh: true)
                                } else { return }   // TODO: else 처리에 어떻게 해야할지?
                            } else {
                                // 그 외에는 네트워크 요청 재시도 처리
                                if retryHandler.retry(for: error) {
                                    await apiCall()
                                } else { return }   // TODO: else 처리에 어떻게 해야할지?
                            }
                            return
                        }
                        
                        print("4️⃣ 데이터 디코딩 시작")
                        do {
                            let decodedData = try JSONDecoder().decode(T.self, from: data)
                            print("✨ 데이터 디코딩 성공")
                            promise(.success(decodedData))
                        } catch {
                            print("🚨 데이터 디코딩 실패", error)
                            promise(.failure(.DecodingError))
                        }
                        
                    } catch {
                        print("🚨 네트워크 요청 실패: \(error)")
                        promise(.failure(.InvalidRequest))
                    }
                }
                await apiCall()
            }
        }
    }
    
    // DTO 반환값 ver.
    func requestDTO<T>(target: APITarget, of type: T.Type) async throws -> T where T: Decodable {
        let retryHandler = NetworkRetryHandler()
        
        // 재귀 호출을 위한 apiCall 내부 함수 정의
        func apiCall(isRefresh: Bool = false) async throws -> T {
            do {
                print("1️⃣ URLRequest 생성 시작")
                var request = try target.asURLRequest()
                
                // 토큰 갱신 후에는 Request Header를 다시 가져와야 하므로 URLRequest 재생성
                if isRefresh {
                    request = try target.asURLRequest()
                }
                
                guard let request = request else {
                    print("🚨 리퀘스트 생성 실패")
                    throw NetworkError.InvalidRequest
                }
                
                print("✨ URLRequest 생성 성공")
                print("2️⃣ 네트워크 요청 시작")
                let (data, response) = try await self.session.data(for: request)
                
                print("3️⃣ 네트워크 응답 받음")
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    // 응답은 왔지만 상태코드가 200이 아닐 때
                    print("🚨 유효하지 않은 응답 (StatusCode: \(httpResponse.statusCode))")
                    let error = NetworkError(rawValue: httpResponse.statusCode) ?? .InvalidResponse
                    // 상태코드 419일 때 토큰 갱신 처리
                    if error == .ExpiredAccessToken || error == .InvalidToken {
                        if await self.refreshToken() {
                            // 토큰 갱신 성공했을 때 기존 호출 재시도
                            return try await apiCall(isRefresh: true)
                        } else {
                            throw error   // TODO: 추가 에러 처리 확인 필요
                        }
                    } else {
                        // 그 외에는 네트워크 요청 재시도 처리
                        if retryHandler.retry(for: error) {
                            return try await apiCall()
                        } else {
                            throw error   // TODO: 추가 에러 처리 확인 필요, 리프레쉬 만료 시 예외처리 해주기!
                        }
                    }
                }
                
                print("4️⃣ 데이터 디코딩 시작")
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    print("✨ 데이터 디코딩 성공")
                    return decodedData
                } catch {
                    print("🚨 데이터 디코딩 실패", error)
                    throw NetworkError.DecodingError
                }
                
            } catch {
                print("🚨 네트워크 요청 실패: \(error)")
                throw NetworkError.InvalidRequest
            }
        }
        
        return try await apiCall()
    }
    
    // MARK: - Post
    // 게시물 포스팅 함수 예시 (리턴값 ver)
    func postCommunity() async throws -> Future<PostDTO, NetworkError> {
        let body = PostBody(category: "자유게시판", title: "강아지 산책 잘 시키는 법", price: 0, content: "강아지 산책 어케 시키나요;;?? 처음이라", files: [], longitude: 126.886557, latitude: 37.51775)
        return try await request(target: .post(.post(body: body)), of: PostDTO.self)
    }
    
    // MARK: - User
    // 내 프로필 조회 함수 예시!
    func fetchProfile() async {
        do {
            let future = try await request(target: .user(.myProfile), of: MyProfileDTO.self)
            future
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("프로필 요청 완료")
                    case .failure(let error):
                        print("프로필 요청 실패: \(error)")
                    }
                } receiveValue: { profileData in
                    print("성공적으로 가져온 프로필 데이터: \(profileData.toDomain())")
                }
                .store(in: &cancellables)
        } catch {
            print("프로필 요청 생성 실패: \(error)")
        }
    }
    
    // MARK: - Auth
    // 토큰 갱신
    func refreshToken() async -> Bool {
        let retryHandler = NetworkRetryHandler()
        
        print("🌀 토큰 갱신 시작")
        func apiCall() async -> Bool {
            do {
                guard let request = try AuthTarget.refreshToken.asURLRequest() else {
                    print("🚨 토큰 갱신 URLRequest 생성 실패")
                    return false
                }
                
                print("✨ 토큰 갱신 URLRequest 생성 성공")
                print("🍀 토큰 갱신 요청 시작")
                let (data, response) = try await session.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    // 응답은 왔지만 상태코드가 200이 아닐 때
                    print("🚨 유효하지 않은 응답 (StatusCode: \(httpResponse.statusCode))")
                    let error = NetworkError(rawValue: httpResponse.statusCode) ?? .InvalidResponse
                    if retryHandler.retry(for: error) {
                        return await apiCall()
                    } else { return false }   // TODO: else 처리에 어떻게 해야할지?
                }
                
                print("4️⃣ 데이터 디코딩 시작")
                do {
                    let decodedData = try JSONDecoder().decode(AuthDTO.self, from: data)
                    print("✨ 데이터 디코딩 성공")
                    UserManager.shared.acess = decodedData.accessToken
                    UserManager.shared.refresh = decodedData.refreshToken
                    return true
                } catch {
                    print("🚨 데이터 디코딩 실패", error)
                    return false
                }
            } catch {
                print("🚨 토큰 갱신 요청 실패: \(error)")
                return false
            }
        }
        return await apiCall()
    }
}

extension NetworkManager {
    //전체 포스터 조회
    func fetchPosts(category: [String]?, isPaging: Bool) async throws -> [PostModel] {
        if (isPaging == false) {
            self.page = ""
        }
        let query = GetPostQuery(next: self.page, limit: "20", category: category)
        //let future = try await request(target: .post(.getPosts(query: query)), of: PostResponseDTO.self)
        let decodedResponse = try await requestDTO(target: .post(.getPosts(query: query)), of: PostResponseDTO.self)
        self.page = decodedResponse.next_cursor
        return decodedResponse.data.map{$0.toDomain()}
    }
    
    //위치 포스터 조회
    func fetchAreaPosts(category: CommunityCategoryType, lon: String, lat: String) async throws -> [PostModel]{
        //        let query = GetGeoLocationQuery(category: ["산책인증"], longitude: lon, latitude: lat, maxDistance: "5000", order_by: OrderType.createdAt.rawValue, sort_by: SortType.asc.rawValue)
        //        let future = try await requestDTO(target: .post(.geolocation(query: query)), of: GeolocationPostResponseDTO.self)
        //        print(future)
        //        print("-----------")
        //        return future.data.map {$0.toDomain()}
        let categoryQuery = category == .all ? "" : "?category=\(category.rawValue)"
        guard var urlComponents = URLComponents(string: APIKey.baseURL + "/posts/geolocation" + categoryQuery) else {
            throw NetworkError.InvalidURL
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "latitude", value: lat),
            URLQueryItem(name: "longitude", value: lon),
            URLQueryItem(name: "maxDistance", value: "5000"),
        ]
        guard let url = urlComponents.url else { throw NetworkError.InvalidURL }
        var request = URLRequest(url: url)
        request.addValue(APIKey.appID, forHTTPHeaderField: BaseHeader.productId.rawValue)
        request.addValue(UserManager.shared.acess, forHTTPHeaderField: BaseHeader.authorization.rawValue)
        request.addValue(APIKey.key, forHTTPHeaderField: BaseHeader.sesacKey.rawValue)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200 else {
            throw NetworkError.InvalidResponse
        }
        do {
            let decodedResponse = try JSONDecoder().decode(GeolocationPostResponseDTO.self, from: data)
            print(decodedResponse.data.map {$0.toDomain()})
            return decodedResponse.data.map {$0.toDomain()}
        } catch {
            print("Decoding Error: \(error)")
            throw NetworkError.DecodingError
        }
    }
    
    
    
    // 한개 포스트 조회
    func fetchDetailPost(id: String) async throws -> Future<PostModel, NetworkError> {
        let future = try await request(target: .post(.getPostsDetail(postID: id)), of: PostDTO.self)
        return Future { promise in
            future
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("✨ 디테일 게시글 요청 성공")
                    case .failure(let error):
                        print("🚨 디테일 게시글 요청 실패: \(error)")
                        promise(.failure(error))
                    }
                } receiveValue: { postResponse in
                    let post = postResponse.toDomain()
                    promise(.success(post))
                }
                .store(in: &self.cancellables)
        }
    }
    // 댓글 작성
    func addContent(id: String, content: String) async throws -> Future<CommentModel, NetworkError> {
        let future = try await request(target: .post(.addContent(postID: id, body: CommentBody(content: content))), of: CommentDTO.self)
        return Future { promise in
            future
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("✨ 댓글 작성 요청 성공")
                    case .failure(let error):
                        print("🚨 댓글 작성 요청 실패: \(error)")
                        promise(.failure(error))
                    }
                } receiveValue: { response in
                    let comment = response.toDomain()
                    promise(.success(comment))
                }
                .store(in: &self.cancellables)
        }
    }
    // 좋아요
    func postLike(id: String, status: Bool) async throws -> Future<LikePostModel, NetworkError> {
        let body = LikePostBody(like_status: status)
        let future = try await request(target: .post(.postLike(postID: id, body: body)), of: LikePostDTO.self)
        return Future { promise in
            future
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("✨ 좋아요 요청 성공")
                    case .failure(let error):
                        print("🚨 좋아요 요청 실패: \(error)")
                        promise(.failure(error))
                    }
                } receiveValue: { likeResponse in
                    let like = likeResponse.toDomain()
                    promise(.success(like))
                }
                .store(in: &self.cancellables)
        }
    }
    // 조회수 증가
    func addViews(id: String) async {
        let body = LikePostBody(like_status: true)
        do {
            let future = try await request(target: .post(.postView(postID: id, body: body)), of: LikePostDTO.self)
            future
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("조회수 요청 완료")
                    case .failure(let error):
                        print("조회수 요청 실패: \(error)")
                    }
                } receiveValue: { profileData in
                    print("성공적으로 완료!")
                }
                .store(in: &cancellables)
        } catch {
            print("조회수 증가 실패 \(error)")
        }
    }
    
    func uploadImagePost(imageData: Data) async throws -> FileModel {
        do {
            let future = try await requestDTO(target: .post(.files(body: ImageUploadBody(files: [imageData]))), of: FileDTO.self)
            return future.toDomain()
        } catch {
            throw NetworkError.UnknownError
        }
    }
    //게시글 작성
    func writePost(body: PostBody) async throws {
        do {
            let _ = try await requestDTO(target:.post(.post(body: body)), of: PostDTO.self)
        } catch {
            print("게시글 작성 오류!!\(error)")
        }
    }
}
// MARK: - 채팅방 부분
extension NetworkManager {
    func makeNewChattingRoom(id: String) async {
        let body = NewChatRoomBody(opponent_id: id)
        do {
            let future = try await request(target: .chat(.newChatRoom(body: body)), of: ChattingRoomDTO.self)
            future
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("방 생성 요청 완료")
                    case .failure(let error):
                        print("방 생성 요청 실패: \(error)")
                    }
                } receiveValue: { [weak self] room in
                    guard let self else { return }
                    ChatRepository.shared.createChatRoom(chatRoomData: room.toDomain())
                }
                .store(in: &cancellables)
            
        } catch {
            print("채팅방 생성 실패!\(error)")
        }
    }
}

protocol RequestRetrier {
    func retry(for error: Error) -> Bool
}

// MARK: 네트워크 재시도 함수 (추후 연결할 것!)
final class NetworkRetryHandler: RequestRetrier {
    private let maxRetry: Int
    private var retry: Int
    
    init(maxRetry: Int = 3, retry: Int = 0) {
        self.maxRetry = maxRetry
        self.retry = retry
    }
    
    /**
     `true` - 계속 재시도
     `false` - 재시도 종료
     */
    func retry(for error: Error) -> Bool {
        print("⚠️ 네트워크 재시도")
        if retry < maxRetry {
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .timedOut, .networkConnectionLost:
                    print("🚨 Retry NetWork 연결 상태 문제")
                default:
                    print("🚨 Retry 알 수 없는 에러")
                }
            }
            incrementRetryCount()
            print("Retry: ", retry)
            print("Max: ", maxRetry)
            return true
        } else {
            print("🚨 재시도 횟수 초과! 재시도 종료")
            return false
        }
        
    }
    
    func incrementRetryCount() {
        retry += 1
    }
}

