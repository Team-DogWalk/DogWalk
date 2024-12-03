//
//  ImageCacheManager.swift
//  DogWalk
//
//  Created by 박성민 on 11/11/24.
//

import SwiftUI
@frozen
enum ImageSaveType {
    case cache
    case document
}
final class ImageCacheManager {
    private var urlSession: URLSession
    private let cache: URLCache
    private let network = NetworkManager()
    init(urlSession: URLSession = URLSession(configuration: .ephemeral), cache: URLCache = URLCache(memoryCapacity: 40 * 1024 * 1024, diskCapacity: 400 * 1024 * 1024)) {
        self.urlSession = urlSession
        self.cache = cache
    }
    
    func getImage(_ urlStr: String, saveType: ImageSaveType = .cache) async -> UIImage {
        do {
            let request = try getBaseRequest(urlStr: urlStr)
            let networkEtag = try await fetchEtag(request: request)
            let isNeedNetwrok = checkEtag(request: request, networkEtag: networkEtag)
            // MARK: - 네트워크 필요 유무 판별
            if isNeedNetwrok { //네트워크 필요 없음!
                switch saveType {
                case .cache:
                    return getToCache(request: request)
                case .document:
                    return getToDocument(request: request)
                }
            } else { //네트워크 필요!
                let result = try await fetchImage(request: request, saveType: saveType)
                return result
            }
            
        } catch {
            guard let networkErr = error as? NetworkError else { return .test}
            print("🚨이미지 캐싱 오류 발생!!!! : \(networkErr)")
            return .test
        }
        
    }
}
// MARK: - Etage 부분
private extension ImageCacheManager {
    // Etage만 확인
    func fetchEtag(request: URLRequest) async throws -> String {
        var headRequest = request
        headRequest.httpMethod = "HEAD"
        let (_, response) = try await urlSession.data(for: headRequest)
        guard let httpURLResponse = response as? HTTPURLResponse else { throw NetworkError.InvalidRequest }
        
        if httpURLResponse.statusCode == 200 {
            return httpURLResponse.allHeaderFields["Etag"] as? String ?? ""
        }
        else if httpURLResponse.statusCode == 419 {
            if await network.refreshToken() {
                print("토큰 갱신")
                return try await fetchEtag(request: request)
            }
        } else {
            if httpURLResponse.statusCode == 444 {
            } else {
                throw NetworkError.ServerError
            }
        }
        return ""
    }
    // 로컬 Etage랑 네트워크 Etag 비교
    func checkEtag(request: URLRequest, networkEtag: String) -> Bool {
        guard let id = request.url?.absoluteString else { return false }
        guard let localEtag = UserManager.shared.imageCache[id] else { return false }
        if localEtag != networkEtag { return false }
        return true
    }
    // tag 저장
    func saveEtage(request: URLRequest, etag: String) {
        guard let id = request.url?.absoluteString else { return }
        UserManager.shared.imageCache[id] = etag
    }
}
private extension ImageCacheManager {
    //BaseRequest 반환
    func getBaseRequest(urlStr: String) throws -> URLRequest {
        guard let url = URL(string: APIKey.baseURL + "/" + urlStr) else { throw NetworkError.InvalidURL}
        var request = URLRequest(url: url)
        request.addValue(APIKey.key, forHTTPHeaderField: BaseHeader.sesacKey.rawValue)
        request.addValue(APIKey.appID, forHTTPHeaderField: BaseHeader.productId.rawValue)
        request.addValue(UserManager.shared.acess, forHTTPHeaderField: BaseHeader.authorization.rawValue)
        request.addValue(BaseHeader.json.rawValue, forHTTPHeaderField: BaseHeader.contentType.rawValue)
        return request
    }
    //캐시된 이미지가 아닌경우 네트워킹
    func fetchImage(request: URLRequest, saveType: ImageSaveType) async throws -> UIImage {
        let (data, response) = try await urlSession.data(for: request)
        guard let httpURLResponse = response as? HTTPURLResponse else { throw NetworkError.InvalidURL }
        if httpURLResponse.statusCode == 200 {
            let image = UIImage(data: data)
            let etag = httpURLResponse.allHeaderFields["Etag"] as? String ?? ""
            saveEtage(request: request, etag: etag) //가져온 이미지의 etag으로 갱신 또는 업데이트 진행
            // MARK: - 저장 타입에 따라 저장 방식 분리
            switch saveType {
            case .cache:
                saveToCache(request: request, response: response, data: data)
            case .document:
                saveToDocument(request: request, data: data)
            }
            return image ?? .test
        } else if httpURLResponse.statusCode == 419 { //토큰 갱신
            if await network.refreshToken() {
                return try await fetchImage(request: request, saveType: saveType)
                //fetchImage(url: url)
            }
        } else {
            if httpURLResponse.statusCode == 444 {
            } else {
                throw NetworkError.ServerError
            }
        }
        return .test
    }
    // 캐싱 저장
    func saveToCache(request: URLRequest, response: URLResponse, data: Data) {
        let cachedURLResponse = CachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedURLResponse, for: request)
    }
    // document 저장
    func saveToDocument(request: URLRequest, data: Data) {
        // TODO: document에 저장하는 로직 작성하기
        guard let id = request.url?.absoluteString else { return }
    }
    //캐싱 이미지 불러오기
    func getToCache(request: URLRequest) -> UIImage {
        if let cacheData = cache.cachedResponse(for: request)?.data, let image = UIImage(data: cacheData) {
            return image
        } else {
            return .test
        }
    }
    //Document에서 id로 이미지 가져오기
    func getToDocument(request: URLRequest) -> UIImage {
        // TODO: document에 저장된 이미지 가져오기
        return .test
    }
}

