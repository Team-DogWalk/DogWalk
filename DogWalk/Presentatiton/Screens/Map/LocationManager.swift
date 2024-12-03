//
//  LocationManager.swift
//  DogWalk
//
//  Created by 소정섭 on 11/6/24.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate , ObservableObject {
    var locationManager =  CLLocationManager ()
    var walkDistance: Double = 0
    var lastLocation: CLLocation!
    
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    @Published var locations: [CLLocationCoordinate2D] = []//사용자의 경로 저장
    @Published var isTrackingPath = false // 산책 경로 기록 중인지 확인

    override init() {
        super.init()
        locationManager.delegate =  self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest// 정확도 설정 (원하는 정확도 설정 가능)
        locationManager.distanceFilter = 5 //TODO: Test / 5미터마다 위치 갱신 수정!
        locationManager.pausesLocationUpdatesAutomatically = true
        checkLocationAuthorization()
    }
    // 위치 권한 확인 및 위치 업데이트 시작
    func checkLocationAuthorization () {
        switch locationManager.authorizationStatus {
        case .notDetermined://사용자가 앱이 위치를 가져오도록 허용할지 거부할지 선택합니다
            locationManager.requestWhenInUseAuthorization()// 위치 권한 요청
            
        case .restricted: //사용자는 이 앱의 상태를 변경할 수 없습니다.아마도 보호자 관리와 같은 활성 제한이 있기 때문일 수 있습니다.
            print ("위치 제한됨")
            
        case .denied: //사용자가 앱에서 위치 정보를 가져오는 것을 거부했거나 위치 서비스를 비활성화했거나 휴대전화가 비행기 모드임
            print ("위치 거부됨")
            
        case .authorizedAlways, .authorizedWhenInUse: //이 권한을 사용하면 앱이 사용 중이든 아니든 모든 위치 서비스를 사용하고 위치 이벤트를 수신할 수 있습니다.
            locationManager.startUpdatingLocation() // 위치 업데이트 시작
            
            if let location = locationManager.location {
                lastKnownLocation = location.coordinate
            }
            
        @unknown default :
            print ( "위치 서비스 비활성화됨" )
        }
    }
    // 위치 권한 상태 변경 시 호출되는 메서드
    func locationManagerDidChangeAuthorization ( _ manager: CLLocationManager ) { //인증 상태가 변경될 때마다 트리거됨
        checkLocationAuthorization()
    }
    // 위치 정보가 업데이트되면 호출되는 메서드
    func locationManager ( _  manager : CLLocationManager , didUpdateLocations  locations : [ CLLocation ]) {
        // 위치 정보 업데이트
        guard let newLocation = locations.last else { return }
        let coordinate = newLocation.coordinate
        lastKnownLocation = coordinate
        // 경로 기록이 활성화된 경우에만 위치 변경 시마다 경로에 추가
        if isTrackingPath {
            self.locations.append(coordinate)
            print("\(Date.now) 현재 위치: \(coordinate.latitude), \(coordinate.longitude)")
            //움직인 거리 계산
            walkDistance += lastLocation.distance(from: newLocation)
            print("움직인 거리: \(walkDistance)")
        }
        lastLocation = newLocation
    }
    // 경로 기록 초기화
    func resetLocations() {
        locations.removeAll()
    }
}
