//
//  ContentState.swift
//  DogWalk
//
//  Created by 박성민 on 11/19/24.
//

import Foundation

@frozen
enum ContentState {
    case loading
    case content
    case error
}

// TODO: 공용으로 사용해도 되는지 확인 필요!
@frozen
enum CommonViewState {
    case loading
    case content
    case error
}
