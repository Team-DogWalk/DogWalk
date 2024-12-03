//
//  CLLocation+.swift
//  DogWalk
//
//  Created by 김윤우 on 11/19/24.
//

import CoreLocation

enum GeoCodingError: Error {
    case noPlacemarksFound
    case locationNotConvertible
    case failedRequest(description: String)
}

//WeatherKit에서 오는 주소 전체에서 동 필터 함수
extension CLLocation {
    func toAddress() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(self) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let placemark = placemarks?.first {
                    let address = placemark.subLocality ?? "설정된 동네가 없어요"
                    continuation.resume(returning: address)
                } else {
                    continuation.resume(throwing: GeoCodingError.noPlacemarksFound)
                }
            }
        }
    }
}
