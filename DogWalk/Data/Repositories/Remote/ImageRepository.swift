//
//  ImageRepository.swift
//  DogWalk
//
//  Created by 박성민 on 12/2/24.
//

import Foundation
@frozen
enum ImageSaveType {
    case cache
    case document
}
final class ImageRepository {
    private let userManager = UserManager.shared
    private let network = NetworkManager()
    private var urlSession: URLSession
    private let cache: URLCache
    
    init(urlSession: URLSession = URLSession(configuration: .ephemeral), cache: URLCache = URLCache(memoryCapacity: 4000 * 1024 * 1024, diskCapacity: 0)) {
        self.urlSession = urlSession
        self.cache = cache
    }
    func getImageData(url: String, saveType: ImageSaveType = .cache) async throws -> Data? {
        switch saveType {
        case .cache:
            return try await getImageToNetwork(url: url)
        case .document:
            return try await getImageToDocument(url: url)
        }
    }
    
}

private extension ImageRepository {
    // 영구저장 이미지
    func getImageToDocument(url: String) async throws -> Data? {
        //etage 확인
        let request = try getBaseRequest(urlStr: url)
        if let etage = userManager.imageCache[url] {
            let networkEtage = try await fetchEtag(request: request)
            if networkEtage == etage {
                return loadImageFilePath(url: url)
            }
        }
        return try await fetchImage(request: request, saveType: .document)
    }
    // 캐싱 이미지
    func getImageToNetwork(url: String) async throws -> Data? {
        let request = try getBaseRequest(urlStr: url)
        if let saveImage = getToCache(request: request) {
            return saveImage
        }
        return try await fetchImage(request: request, saveType: .cache)
    }
}
// MARK: - 캐싱 부분
private extension ImageRepository {
    // 캐싱 저장
    func saveToCache(request: URLRequest, response: URLResponse, data: Data) {
        let cachedURLResponse = CachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedURLResponse, for: request)
    }
    //캐싱 이미지 불러오기
    func getToCache(request: URLRequest) -> Data? {
        if let cacheData = cache.cachedResponse(for: request)?.data{
            print("캐싱 이미지 가져옴!!!")
            return cacheData
        } else {
            return nil
        }
    }

}
// MARK: - Document 부분
private extension ImageRepository {
    // Document 이미지 저장
    func saveToDocument(imageData: Data, url: String, etage: String) {
        guard let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else { return }
        let fileURL = documentDirectory.appendingPathComponent(url)
        do {
            userManager.imageCache[url] = etage // 이태그 정보 저장
            try imageData.write(to: fileURL) // 이미지 데이터 저장
        } catch {
            print("file save error", error)
        }
    }
    // Document 이미지 가져오기
    func loadImageFilePath(url: String) -> Data? {
        // 1. Document Directory 경로를 가져옵니다.
        guard let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            print("Document directory 경로를 가져올 수 없습니다.")
            return nil
        }
        
        // 2. 이미지 파일의 전체 경로를 구성합니다.
        let fileURL = documentDirectory.appendingPathComponent(url)
        
        // 3. 파일이 존재하는지 확인합니다.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // 4. 파일의 데이터를 읽어옵니다.
                let imageData = try Data(contentsOf: fileURL)
                return imageData
            } catch {
                print("이미지 데이터를 읽는 도중 에러 발생: \(error)")
                return nil
            }
        } else {
            print("파일이 존재하지 않습니다: \(fileURL.path)")
            return nil
        }
    }
}
// MARK: - 통신 부분
private extension ImageRepository {
    // request 만들기~
    func getBaseRequest(urlStr: String) throws -> URLRequest {
        guard let url = URL(string: APIKey.baseURL + "/" + urlStr) else { throw NetworkError.InvalidURL}
        var request = URLRequest(url: url)
//        request.cachePolicy = .reloadIgnoringCacheData // etag 통신시 304에러 보고싶을 때 이걸로 ㄱㄱ
        request.addValue(APIKey.key, forHTTPHeaderField: BaseHeader.sesacKey.rawValue)
        request.addValue(APIKey.appID, forHTTPHeaderField: BaseHeader.productId.rawValue)
        request.addValue(UserManager.shared.acess, forHTTPHeaderField: BaseHeader.authorization.rawValue)
        request.addValue(BaseHeader.json.rawValue, forHTTPHeaderField: BaseHeader.contentType.rawValue)
        request.cachePolicy = .returnCacheDataElseLoad
        return request
    }
    //이미지 다운
    func fetchImage(request: URLRequest, saveType: ImageSaveType) async throws -> Data? {
        let (data, response) = try await urlSession.data(for: request)
        guard let httpURLResponse = response as? HTTPURLResponse else { throw NetworkError.InvalidURL }
        if httpURLResponse.statusCode == 200 {
            let etag = httpURLResponse.allHeaderFields["Etag"] as? String ?? ""
            // MARK: - 저장 타입에 따라 저장 방식 분리
            switch saveType {
            case .cache:
                saveToCache(request: request, response: response, data: data)
            case .document:
                saveToDocument(imageData: data, url: request.debugDescription, etage: etag)
                //saveToDocument(request: request, data: data)
            }
            return data
        } else if httpURLResponse.statusCode == 419 { //토큰 갱신
            let result = try await network.refreshToken()
            var reRequest = request
            reRequest.setValue(result.accessToken, forHTTPHeaderField: BaseHeader.authorization.rawValue)
            return try await fetchImage(request: reRequest, saveType: saveType)
        } else {
            if httpURLResponse.statusCode == 444 {
            } else {
                throw NetworkError.ServerError
            }
        }
        return Data()
    }
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
            let result = try await network.refreshToken()
            var reRequest = request
            reRequest.setValue(result.accessToken, forHTTPHeaderField: BaseHeader.authorization.rawValue)
            return try await fetchEtag(request: reRequest)
        } else {
            if httpURLResponse.statusCode == 444 {
            } else {
                throw NetworkError.ServerError
            }
        }
        return ""
    }
}
