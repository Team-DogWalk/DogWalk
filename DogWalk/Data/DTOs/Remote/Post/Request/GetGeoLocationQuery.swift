//
//  GetGeoLocationQuery.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 위치 기반 게시글 조회 쿼리 (Request)
struct GetGeoLocationQuery: Encodable {
    let category: [String]?
    let longitude: String   // 왜 문자열일까?
    let latitude: String    // 왜 문자열일까?
    let maxDistance: String
    let order_by: OrderType.RawValue
    let sort_by: SortType.RawValue
}

/**
 1) `category` : 미입력 시 header의 ProductId를 기준으로 전체 게시글을 조회. 입력 시 category와 함께 필터링하여 게시글을 조회
 2) `longitude` : 경도값(127.886417)
 3) `latitude` : 위도값(37.517682)
 4) `maxDistance` : 500(미터단위) (기본값 500)
 5) `order by` :
 6) `sort by` :
 */

/** 정렬조합 참고
 1) `order_by: distance, sort_by: asc` : 거리가 가까운 순
 2) `order_by: distance, sort_by: desc` : 거리가 먼 순
 3) `order_by: createdAt, sort_by: asc`  : 게시글 생성일이 오래된 순
 4) `order_by: createdAt, sort_by: desc` : 게시글 생성일이 최근인 순
*/

enum OrderType: String {
    case distance = "distance"
    case createdAt = "createdAt"
}

enum SortType: String {
    case asc = "asc"
    case desc = "desc"
}
