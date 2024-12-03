//
//  PostTarget.swift
//  DogWalk
//
//  Created by junehee on 11/2/24.
//

import Foundation

enum PostTarget {
    case files(body: ImageUploadBody)                          // 파일 업로드
    case post(body: PostBody)                               // 게시글 작성
    case getPosts(query: GetPostQuery)                      // 게시글 조회
    case getPostsDetail(postID: String)                     // 게시글 상세 조회
    case putPost(postID: String)                            // 게시글 수정
    case deletePost(postID: String)                         // 게시글 삭제
    case postLike(postID: String, body: LikePostBody)       // 게시글 좋아요 (Like-1)
    case myLikePosts(query: GetPostQuery)                   // 내가 좋아요한 게시물 조회
    case postView(postID: String, body: LikePostBody)       // 게시글 방문 (Like-2)
    case myViewPosts(query: GetPostQuery)                   // 내가 방문한 게시물 조회
    case userPosts(userID: String, query: GetPostQuery)     // 다른 유저가 작성한 게시물 조회
    case hashtag(query: GetHashTagQuery)                    // 해시태그 검색
    case geolocation(query: GetGeoLocationQuery)            // 위치 기반 게시글 검색
    case addContent(postID: String, body: CommentBody)        // 댓글 작성
}

extension PostTarget: TargetType {
    var baseURL: String {
        return APIKey.baseURL
    }
    
    var path: String {
        switch self {
        case .files:
            return "/posts/files"
        case .post, .getPosts:
            return "/posts"
        case .getPostsDetail(let postID), .putPost(let postID), .deletePost(let postID):
            return "posts/\(postID)"
        case .postLike(let postID, _):
            return "/posts/\(postID)/like"
        case .myLikePosts:
            return "/posts/likes/me"
        case .postView(let postID, _):
            return "/posts/\(postID)/like-2"
        case .myViewPosts:
            return "/posts/likes-2/me"
        case .userPosts(let userID, _):
            return "/posts/users/\(userID)"
        case .hashtag:
            return "/posts/hashtags"
        case .geolocation:
            return "/posts/geolocation"
        case .addContent(let id, _):
            return "/posts/\(id)/comments"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .files, .post, .postLike, .postView, .addContent:
            return .post
        case .getPosts, .getPostsDetail, .myLikePosts, .myViewPosts, .userPosts, .hashtag, .geolocation:
            return .get
        case .putPost:
            return .put
        case .deletePost:
            return .delete
        }
    }
    
    var header: [String : String] {
        switch self {
            /// productID, multipart-form, authorizaiton, sesacKey
        case .files(let body):
            return [
                BaseHeader.productId.rawValue: APIKey.appID,
                BaseHeader.contentType.rawValue: BaseHeader.multipart.rawValue + "; boundary=\(body.boundary)",  // multipart-form
                BaseHeader.authorization.rawValue: UserManager.shared.acess,
                BaseHeader.sesacKey.rawValue: APIKey.key,
            ]
            /// productID, application/json, authorizaiton, sesacKey
        case .post, .putPost, .deletePost, .postLike, .postView, .addContent:
            return [
                BaseHeader.productId.rawValue: APIKey.appID,
                BaseHeader.contentType.rawValue: BaseHeader.json.rawValue,
                BaseHeader.authorization.rawValue: UserManager.shared.acess,
                BaseHeader.sesacKey.rawValue: APIKey.key
            ]
            /// productID, authorizaiton, sesacKey
        case .getPosts, .getPostsDetail, .hashtag, .geolocation, .myLikePosts, .myViewPosts, .userPosts:
            return [
                BaseHeader.productId.rawValue: APIKey.appID,
                BaseHeader.authorization.rawValue: UserManager.shared.acess,
                BaseHeader.sesacKey.rawValue: APIKey.key
            ]
        }
    }
    
    var query: [URLQueryItem]? {
        let encoder = JSONEncoder()
        
        switch self {
        case .getPosts(let query):
            do {
                let data = try encoder.encode(query)
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
                var items = [URLQueryItem]()
                for (key, value) in json {
                    if let array = value as? [Any] {
                        for element in array {
                            items.append(URLQueryItem(name: key, value: "\(element)"))
                        }
                    } else {
                        items.append(URLQueryItem(name: key, value: "\(value)"))
                    }
                }
                return items
            } catch {
                print("Query to JSON Encode Error!", error)
                return nil
            }
        case .myLikePosts(let query), .myViewPosts(let query), .userPosts(_, let query):
            do {
                let data = try encoder.encode(query)
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
                return json.map { URLQueryItem(name: $0, value: "\($1)")}
            } catch {
                print("Query to JSON Encode Error!", error)
                return nil
            }
        case .hashtag(let query):
            do {
                let data = try encoder.encode(query)
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
                return json.map { URLQueryItem(name: $0, value: "\($1)")}
            } catch {
                print("Query to JSON Encode Error!", error)
                return nil
            }
        case .geolocation(let query):
            do {
                let data = try encoder.encode(query)
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
                var items = [URLQueryItem]()
                for (key, value) in json {
                    if let array = value as? [Any] {
                        for element in array {
                            items.append(URLQueryItem(name: key, value: "\(element)"))
                        }
                    } else {
                        items.append(URLQueryItem(name: key, value: "\(value)"))
                    }
                }
                return items
            } catch {
                print("Query to JSON Encode Error!", error)
                return nil
            }
        default:
            return nil
        }
    }
    
    var body: Data? {
        let encoder = JSONEncoder()
        
        switch self {
        case .files(let body):
            return asMultipartFileDatas(for: body.boundary, key: "files", values: body.files, filename: "\(APIKey.appID)PostImage")
        case .post(let body):
            do {
                let data = try encoder.encode(body)
                return data
            } catch {
                print("Body to JSON Encode Error", error)
                return nil
            }
        case .postLike(_, let body):
            do {
                let data = try encoder.encode(body)
                return data
            } catch {
                print("Body to JSON Encode Error", error)
                return nil
            }
        case .postView(_, let body):
            do {
                let data = try encoder.encode(body)
                return data
            } catch {
                print("Body to JSON Encode Error", error)
                return nil
            }
        case .addContent(_, let body):
            do {
                let data = try encoder.encode(body)
                return data
            } catch {
                print("Body to JSON Encode Error", error)
                return nil
            }
        default:
            return nil
        }
    }
    
    // var boundary: String {
    //     return nil
    // }
}
