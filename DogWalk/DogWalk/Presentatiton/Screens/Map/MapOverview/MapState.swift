//
//  MapState.swift
//  DogWalk
//
//  Created by 소정섭 on 11/12/24.
//

import SwiftUI
import MapKit
import Combine
//MARK: 데이터 관련 프로토콜
protocol MapStateProtocol { // 속성들을 가지는 프로토콜
    var isShowingSheet: Bool { get }
    var visibleRegion: MKCoordinateRegion { get }
    //Timer
    var count: Int { get }
    var timer: DispatchSourceTimer? { get }
    var isTimerOn: Bool { get }
    var isAlert: Bool { get }
    //현위치
    var posts: [PostModel] { get }
    var locationManager: LocationManager { get }
    var position: MapCameraPosition { get }
    var polylineColor: Color { get }
    //지도를 이미지로 저장
    var routeImage: UIImage { get }
    var selectedAnnotation: PostModel { get }
}
protocol MapActionProtocol: AnyObject { // 메서드을 가지고있는 프로토콜
    func setTimerOn(_ isOn: Bool)
    func resetCount()
    func incrementCount()
    func startLocationTracking()
    func stopLocationTracking()
    func setAlert(_ isOn: Bool)
    func saveCapturedRouteImage(_ image: UIImage)
    func getPolylineColor() -> Color
    func startBackgroundTimer()
    func stopTimer()
    func getCenter(_ region: MKCoordinateRegion)
    func updatePosition(_ newPosition: MapCameraPosition)
    func getPosts(_ data: [PostModel])
    func getSelectedAnnotation(_ post: PostModel)
}
//MARK: - view에 전달할 데이터
@Observable
final class MapState: MapStateProtocol, ObservableObject {
    var isShowingSheet: Bool = false
    var visibleRegion: MKCoordinateRegion = MKCoordinateRegion()
    //Timer
    var posts: [PostModel] = []
    var count: Int = 0
    var timer: DispatchSourceTimer?
    var isTimerOn : Bool = false
    var isAlert: Bool = false
    var selectedAnnotation: PostModel = PostModel()
    
    //현위치
    var locationManager = LocationManager()
    var position: MapCameraPosition = .userLocation(fallback: .automatic)
    var polylineColor = Color(
        red: Double.random(in: 0...1),
        green: Double.random(in: 0...1),
        blue: Double.random(in: 0...1)
    )
  
    //지도를 이미지로 저장
    var routeImage: UIImage = UIImage(resource: .testProfile)
}
// MARK: - intent에 줄 함수
extension MapState: MapActionProtocol {
    func getSelectedAnnotation(_ post: PostModel) {
        self.selectedAnnotation = post
    }
    func getPosts(_ data: [PostModel]) {
        self.posts = data
    }
    
    func setTimerOn(_ isOn: Bool) {
        isTimerOn = isOn
    }
    
    func resetCount() {
        count = 0
    }
    
    func incrementCount() {
        count += 1
    }
    
    func startLocationTracking() {
        locationManager.isTrackingPath = true
        locationManager.resetLocations()
    }
    
    func stopLocationTracking() {
        locationManager.isTrackingPath = false
    }
    
    func setAlert(_ isOn: Bool) {
        isAlert = isOn
    }
    //지도를 이미지에 저장
    func saveCapturedRouteImage(_ image: UIImage) {
        self.routeImage = image
    }
    //지도 이미지에 색 전달
    func getPolylineColor() -> Color {
        return self.polylineColor
    }
    
    func startBackgroundTimer() {
        guard timer == nil else {
            print("타이머가 이미 실행 중입니다.")
            return
        }
        
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        
        timer?.schedule(deadline: .now(), repeating: 1)
        
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            if self.count < 6 * 60 * 60 {
                DispatchQueue.main.async {
                    self.incrementCount()
                    print(self.count)
                }
            } else {
                DispatchQueue.main.async {
                    self.stopTimer()
                }
            }
        }
        timer?.resume()
        print("타이머가 시작되었습니다.")
    }
    
    func stopTimer() {
        timer?.cancel()
        timer = nil
        print("타이머가 중지되었습니다.")
    }
    
    func getCenter(_ region: MKCoordinateRegion) {
        visibleRegion = region
    }
    
    func updatePosition(_ newPosition: MapCameraPosition) {
        position = newPosition
    }
}
