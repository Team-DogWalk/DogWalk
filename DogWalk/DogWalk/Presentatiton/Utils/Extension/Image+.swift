//
//  Image+.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import SwiftUI

extension Image {
    static let asXmark = Image(systemName: "xmark")                 // x마크
    static let asMessage = Image(systemName: "ellipsis.message")    // 댓글
    static let asHeart = Image(systemName: "heart")                 // 좋아요
    static let asHeartFill = Image(systemName: "heart.fill")        // 채워진 좋아요
    static let asDownChevron = Image(systemName: "chevron.down")    // 문래동 방향키 아래
    static let asPencil = Image(systemName: "square.and.pencil")    // 게시글 작성 버튼
    static let asXmarkFill = Image(systemName: "xmark.circle.fill") // 사진 지우기버튼
    static let asPlus = Image(systemName: "plus")                   // 더하기
    
    // TEST
    static let asTestAdCell = Image("TestAdCell")
    static let asTestLogo = Image("TestLogo")
    static let asTestProfile = Image("TestProfile")
    static let asTestImage = Image("TestImage")
    static let asWalk = Image("TabWalk")
}

