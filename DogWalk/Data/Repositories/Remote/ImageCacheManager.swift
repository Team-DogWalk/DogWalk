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
            let saveImage: UIImage?
            // 캐싱이냐 document 따른 저장 체크!
            if saveType == .document {
                saveImage = loadImageFilePath(url: request.debugDescription)
            } else {
                saveImage = getToCache(request: request)
            }
            //저장된 값이 있는 경우 반환!
            if let image = saveImage {
                return image
            }
            //저장된 값이 없는 경우 이미지 네트워크 진행!
            return try await fetchImage(request: request, saveType: saveType)
            //let networkEtag = try await fetchEtag(request: request)
            //let isNeedNetwrok = checkEtag(request: request, networkEtag: networkEtag)
            // MARK: - 네트워크 필요 유무 판별
//            if isNeedNetwrok { //네트워크 필요 없음!
//                switch saveType {
//                case .cache:
//                    return getToCache(request: request)
//                case .document:
//                    return getToDocument(request: request)
//                }
//            } else { //네트워크 필요!
//                let result = try await fetchImage(request: request, saveType: saveType)
//                return result
//            }
            
        } catch {
            guard let networkErr = error as? NetworkError else { return .test}
            print("🚨이미지 캐싱 오류 발생!!!! : \(networkErr)")
            return .test
        }
        
    }
}
// MARK: - Etage 부분
//private extension ImageCacheManager {
//    // Etage만 확인
//    func fetchEtag(request: URLRequest) async throws -> String {
//        var headRequest = request
//        headRequest.httpMethod = "HEAD"
//        let (_, response) = try await urlSession.data(for: headRequest)
//        guard let httpURLResponse = response as? HTTPURLResponse else { throw NetworkError.InvalidRequest }
//        
//        if httpURLResponse.statusCode == 200 {
//            return httpURLResponse.allHeaderFields["Etag"] as? String ?? ""
//        }
//        else if httpURLResponse.statusCode == 419 {
//            let result = try await network.refreshToken()
//            var reRequest = request
//            reRequest.setValue(result.accessToken, forHTTPHeaderField: BaseHeader.authorization.rawValue)
//            return try await fetchEtag(request: reRequest)
//        } else {
//            if httpURLResponse.statusCode == 444 {
//            } else {
//                throw NetworkError.ServerError
//            }
//        }
//        return ""
//    }
//    // 로컬 Etage랑 네트워크 Etag 비교
//    func checkEtag(request: URLRequest, networkEtag: String) -> Bool {
//        guard let id = request.url?.absoluteString else { return false }
//        guard let localEtag = UserManager.shared.imageCache[id] else { return false }
//        if localEtag != networkEtag { return false }
//        return true
//    }
//    // tag 저장
//    func saveEtage(request: URLRequest, etag: String) {
//        guard let id = request.url?.absoluteString else { return }
//        UserManager.shared.imageCache[id] = etag
//    }
//}
private extension ImageCacheManager {
    //BaseRequest 반환
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
    //캐시된 이미지가 아닌경우 네트워킹
    func fetchImage(request: URLRequest, saveType: ImageSaveType) async throws -> UIImage {
        let (data, response) = try await urlSession.data(for: request)
        guard let httpURLResponse = response as? HTTPURLResponse else { throw NetworkError.InvalidURL }
        if httpURLResponse.statusCode == 200 {
            let image = UIImage(data: data)
//            let etag = httpURLResponse.allHeaderFields["Etag"] as? String ?? ""
//            saveEtage(request: request, etag: etag) //가져온 이미지의 etag으로 갱신 또는 업데이트 진행
            // MARK: - 저장 타입에 따라 저장 방식 분리
            switch saveType {
            case .cache:
                saveToCache(request: request, response: response, data: data)
            case .document:
                saveToDocument(request: request, data: data)
            }
            return image ?? .test
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
        print(id)
        print("----------이미지 저장------")
        self.saveImageToDocument(imageData: data, url: id)
    }
    //캐싱 이미지 불러오기
    func getToCache(request: URLRequest) -> UIImage? {
        if let cacheData = cache.cachedResponse(for: request)?.data, let image = UIImage(data: cacheData) {
            return image
        } else {
            return nil
        }
    }
    //Document에서 id로 이미지 가져오기
//    func getToDocument(request: URLRequest) -> UIImage {
//        guard let id = request.url?.absoluteString else { return .test }
//        print(id)
//        print("----------이미지 불러오기------")
//        let image = loadImageFilePath(url: id)
//        guard let image else {return .test}
//        return image
//    }
}

private extension ImageCacheManager {
    func saveImageToDocument(filename: String) -> UIImage? {
        guard let document = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else { return nil}
        
        let fileURL = document.appendingPathComponent("\(filename).jpg")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            
            return UIImage(systemName: "star.fill")
        }
    }
    
    // Document 이미지 저장
    func saveImageToDocument(imageData: Data, url: String) {
        guard let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else { return }
        let fileURL = documentDirectory.appendingPathComponent(url)
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("file save error", error)
        }
    }
    // Document 이미지 가져오기
    func loadImageFilePath(url: String) -> UIImage? {
        guard let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else { return nil }
        let fileURL = documentDirectory.appendingPathExtension(url)
        if FileManager.default.fileExists(atPath: fileURL.path()) {
            return UIImage(contentsOfFile: fileURL.path())
        } else {
            return nil
        }
//        let fileURL = documentDirectory.appendingPathComponent(url)
//        let filePath: String
//        print(fileURL)
//        
//        if #available(iOS 16.0, *) {
//            filePath = fileURL.path()
//        } else {
//            filePath = fileURL.path
//        }
//        if FileManager.default.fileExists(atPath: filePath) {
//            return UIImage(contentsOfFile: filePath)
//        } else {
//            return nil
//        }
    }
    // Document 이미지 삭제
    func removeImageFromDocument(url: String) {
        guard let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else { return }
        let fileURL = documentDirectory.appendingPathComponent(url)
        let filePath: String
        
        if #available(iOS 16.0, *) {
            filePath = fileURL.path()
        } else {
            filePath = fileURL.path
        }
        
        if FileManager.default.fileExists(atPath: filePath) {
            
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                print("file remove error", error)
            }
            
        } else {
            print("file no exist")
        }
        
    }
}

