//
//  NetworkManager.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import Foundation
import Combine

protocol Requestable {
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
    // DTO 반환값 ver.
    func requestDTO<T>(target: APITarget, of type: T.Type) async throws -> T where T: Decodable {
        let retryHandler = NetworkRetryHandler()
        // 재귀 호출을 위한 apiCall 내부 함수 정의
        func apiCall(request: URLRequest) async throws -> T {
            do {
                print("2️⃣ 네트워크 요청 시작")
                let (data, response) = try await self.session.data(for: request)
                print("3️⃣ 네트워크 응답 받음")
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    // 응답은 왔지만 상태코드가 200이 아닐 때
                    print("🚨 유효하지 않은 응답 (StatusCode: \(httpResponse.statusCode))")
                    let error = NetworkError(rawValue: httpResponse.statusCode) ?? .InvalidResponse
                    // 상태코드 419일 때 토큰 갱신 처리
                    if httpResponse.statusCode == 401 || httpResponse.statusCode == 419 {
                        do {
                            let result = try await self.refreshToken()
                            UserManager.shared.acess = result.accessToken
                            UserManager.shared.refresh = result.refreshToken
                            var reRequest = request
                            //응답받은 access토큰 request에 추가 후 재통신
                            reRequest.setValue(result.accessToken, forHTTPHeaderField: BaseHeader.authorization.rawValue)
                            return try await apiCall(request: reRequest)
                        } catch {
                            if retryHandler.retry(for: error) {
                                return try await apiCall(request: request)
                            } else {
                                throw error
                            }
                        }
                    } else {
                        // 그 외에는 네트워크 요청 재시도 처리
                        if retryHandler.retry(for: error) {
                            return try await apiCall(request: request)
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
        guard let request = try target.asURLRequest() else { throw NetworkError.DecodingError}
        print("✨ URLRequest 생성 성공")
        return try await apiCall(request: request)
    }
    // MARK: - Auth
    // 토큰 갱신
    func refreshToken() async throws -> AuthModel {
        do {
            print("🌀 토큰 갱신 시작")
            guard let request = try AuthTarget.refreshToken.asURLRequest() else {
                print("🚨 토큰 갱신 URLRequest 생성 실패")
                throw NetworkError.InvalidURL
            }
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200 else {
                throw NetworkError.InvalidResponse
            }
            print("✨ 토큰 갱신 URLRequest 생성 성공")
            do {
                let decodedResponse = try JSONDecoder().decode(AuthDTO.self, from: data)
                let result = decodedResponse.toDomain()
                UserManager.shared.acess = result.accessToken
                UserManager.shared.refresh = result.refreshToken
                print("🍀 토큰 갱신 요청 성공")
                return result
            } catch {
                print("Decoding Error: \(error)")
                throw NetworkError.DecodingError
            }
            
        } catch {
            print("🚨 토큰 갱신 요청 실패: \(error)")
            throw error
        }
    }
}


extension NetworkManager {
    //전체 포스터 조회
    func fetchPosts(category: [String]?, isPaging: Bool) async throws -> [PostModel] {
        if (isPaging == false) {
            self.page = ""
        }
        if self.page == "0" { return []}
        let query = GetPostQuery(next: self.page, limit: "20", category: category)
        //let future = try await request(target: .post(.getPosts(query: query)), of: PostResponseDTO.self)
        let decodedResponse = try await requestDTO(target: .post(.getPosts(query: query)), of: PostResponseDTO.self)
        self.page = decodedResponse.next_cursor
        return decodedResponse.data.map{$0.toDomain()}
    }
    
    //위치 포스터 조회
    func fetchAreaPosts(category: CommunityCategoryType, lon: String, lat: String) async throws -> [PostModel]{
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
        let future = try await requestDTO(target: .post(.getPostsDetail(postID: id)), of: PostDTO.self)
        return future.toDomain()
    }
    // 댓글 작성
    func addContent(id: String, content: String) async throws -> CommentModel {
        let future = try await requestDTO(target: .post(.addContent(postID: id, body: CommentBody(content: content))), of: CommentDTO.self)
        return future.toDomain()
    }
    // 좋아요
    func postLike(id: String, status: Bool) async throws -> LikePostModel {
        let body = LikePostBody(like_status: status)
        let future = try await requestDTO(target: .post(.postLike(postID: id, body: body)), of: LikePostDTO.self)
        return future.toDomain()
    }
    // 조회수 증가
    func addViews(id: String) async throws {
        let body = LikePostBody(like_status: true)
        _ = try await requestDTO(target: .post(.postView(postID: id, body: body)), of: LikePostDTO.self)
    }
    //파일 업로드
    func uploadImagePost(imageData: Data) async throws -> FileModel {
        let future = try await requestDTO(target: .post(.files(body: ImageUploadBody(files: [imageData]))), of: FileDTO.self)
        return future.toDomain()
    }
    //게시글 작성
    func writePost(body: PostBody) async throws {
        let _ = try await requestDTO(target:.post(.post(body: body)), of: PostDTO.self)
    }
}


// MARK: - 채팅방 부분
extension NetworkManager {
    func makeNewChattingRoom(id: String) async throws {
        let body = NewChatRoomBody(opponent_id: id)
        _ = try await requestDTO(target: .chat(.newChatRoom(body: body)), of: ChattingRoomDTO.self)
    }
}
extension NetworkManager {
    func appleLogin(id: String) async throws {
        let body = AppleLoginBody(idToken: id, nick: "애플독")
        let result = try await requestDTO(target: .user(.appleLogin(body: body)), of: OAuthLoginDTO.self)
        UserManager.shared.acess = result.accessToken
        UserManager.shared.refresh = result.refreshToken
        UserManager.shared.userID = result.user_id
        UserManager.shared.userNick = "애플독"
        UserManager.shared.isUser = true
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

