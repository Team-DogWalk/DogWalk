//
//  NetworkManager.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import Foundation
import Combine

protocol Requestable {
    func request<T: Decodable>(target: APITarget, of type: T.Type) async throws -> Future<T, NetworkError>
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
                            if error == .ExpiredAccessToken {
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
    func fetchPosts(category: [String]?, isPaging: Bool) async throws -> Future<PostResponseDTO, NetworkError> {
        if (isPaging == false) {
            self.page = ""
        }
        let query = GetPostQuery(next: self.page, limit: "20", category: category)
        return try await request(target: .post(.getPosts(query: query)), of: PostResponseDTO.self)
    }
    //위치 포스터 조회
    func fetchAreaPosts(category: [String]?, lon: String, lat: String) async throws -> Future<[PostDTO], NetworkError> {
        let query = GetGeoLocationQuery(category: category, longitude: lon, latitude: lat, maxDistance: "10000", order_by: OrderType.distance.rawValue, sort_by: SortType.asc.rawValue)
        return try await request(target: .post(.geolocation(query: query)), of: [PostDTO].self)
    }
    //게시글 작성
    func writePost(body: PostBody) async throws -> Future<PostDTO, NetworkError> {
        return try await request(target: .post(.post(body: body)), of: PostDTO.self)
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
                    print("재시도 : \(retry) | 최대시도 : \(maxRetry)")
                    return true
                default: 
                    return true
                }
            }
        } else {
            print("🚨 재시도 횟수 초과! 재시도 종료")
            return false
        }
        incrementRetryCount()
        print("Retry: ", retry)
        print("Max: ", maxRetry)
        return true
    }
    
    func incrementRetryCount() {
        retry += 1
    }
}
