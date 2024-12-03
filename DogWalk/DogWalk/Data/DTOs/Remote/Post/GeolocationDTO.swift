//
//  GeolocationDTO.swift
//  DogWalk
//
//  Created by junehee on 11/3/24.
//

import Foundation

// 위치
struct GeolocationDTO: Decodable {
    let longitude: Double
    let latitude: Double
}

extension GeolocationDTO {
    func toDomain() -> GeolocationModel {
        return GeolocationModel(lat: self.latitude, lon: self.longitude)
    }
}

struct GeolocationModel {
    let lat: Double
    let lon: Double
}
