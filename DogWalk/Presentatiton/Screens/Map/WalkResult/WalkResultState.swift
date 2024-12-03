//
//  WalkResultState.swift
//  DogWalk
//
//  Created by 박성민 on 11/6/24.
//

import SwiftUI

// MARK: - 데이터 관련 프로토콜
protocol WalkResultStateProtocol { // 속성들을 가지는 프토코롤
    var isPresented: Bool { get }
    
    var postDate: String { get }
    var dogNick: String { get }
    var userProfile: String { get }
    
    var walkTime: Int { get }
    var walkDistance: Double { get }
    var walkCalorie: Double { get }
    var METs: Double { get }
    
    var routeImage: UIImage { get }
}

protocol WalkResultActionProtocol: AnyObject { //메서드을 가지고있는 프로토콜
    func calculateCalories()
}

// MARK: - view에게 전달할 데이터
@Observable
final class WalkResultState: WalkResultStateProtocol, ObservableObject {
    var isPresented: Bool = false
    
    var postDate: String  = ""
    var dogNick: String = ""
    var userProfile: String = ""
    
    var walkTime: Int
    var walkDistance: Double
    var walkCalorie: Double
    var METs: Double = 0.0
    
    var routeImage: UIImage
    
    init(walkTime: Int = 0, walkDistance: Double = 0.0, walkCalorie: Double = 0.0, routeImage: UIImage = UIImage(systemName: "star")!) {
        self.walkTime = walkTime
        self.walkDistance = walkDistance
        self.walkCalorie = walkCalorie
        self.routeImage = routeImage
    }
}

// MARK: - intent에 줄 함수
extension WalkResultState: WalkResultActionProtocol {
    func calculateCalories() {
        let time = Double(walkTime/3600)    //시간
        let distance = walkDistance/1000    //km
        
        if distance / time <= 3.2 {
            METs = 2.8
        } else if distance / time <= 4.8 {
            METs = 3.9
        } else if distance / time <= 6.4 {
            METs = 4.5
        } else {
            METs = 6.0
        }
    
        walkCalorie = 70 * distance * METs
    }
}
