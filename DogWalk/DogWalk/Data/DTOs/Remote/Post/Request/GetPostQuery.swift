//
//  GetPostQuery.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 게시글 조회 & 내가 좋아요한 게시글 조회 쿼리 (Request)
struct GetPostQuery: Encodable {
    let next: String?
    let limit: String?
    let category: [String]?
}

/**
 1) `next`: 처음 요청시에는 빈 값으로 요청, 이후 요청부터는 응답 값의 next cursor값을 입력하여 다음 페이지를 요청
 2) `limit`: 한 페이지 당 보여지는 데이터 개수. 입력하지 않은 경우 5개를 요청한 것으로 간주. (1이상 양수값)
 3) `category`: 입력하지 않으면 header의 ProductId를 기준으로 전체 게시글을 조회. 입력한 경우 category와 함께 필터링하여 게시글을 조회.
 */
