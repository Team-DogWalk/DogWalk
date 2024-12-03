//
//  MapIntent.swift
//  DogWalk
//
//  Created by 소정섭 on 11/12/24.
//

import SwiftUI
import MapKit
//MARK: 2.좌표 기반 마커 표시
protocol MapIntentProtocol {
    func startWalk()
    func stopWalk()
    func incrementTimer()
    func showAlert()
    func closeAlert()
    func openAppSettings()
    func setSnapshotOptions(coordinates: [CLLocationCoordinate2D]) -> MKMapSnapshotter.Options
    func getRouteCenterCoordinate(coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D?
    func makeRouteSizeRegion(center: CLLocationCoordinate2D, coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion
    func setRouteImage(route coordinates: [CLLocationCoordinate2D]) async
    func startBackgroundTimer()
    func stopBackgroundTimer()
    func getCenter(_ region: MKCoordinateRegion)
    //MARK: 2.좌표 기반 마커 표시
    func getPostsAtLocation(lat: CLLocationDegrees, lon: CLLocationDegrees)
    func updatePosition(_ newPosition: MapCameraPosition)
    func selectAnnotation(_ post: PostModel)
    func showRefreshButton()
    func hideRefreshButton()
}

final class MapIntent {
    private weak var state: MapActionProtocol?
    private var usecase: MapUseCase
    init(state: MapActionProtocol? = nil, useCase: MapUseCase = DefaultMapUseCase()) {
        self.state = state
        self.usecase = useCase
    }
}

extension MapIntent: MapIntentProtocol {
    func showRefreshButton() {
        state?.showRefreshButton(true)
    }
    
    func hideRefreshButton() {
        state?.showRefreshButton(false)
    }
    
    // 피커 클릭 시
    func selectAnnotation(_ post: PostModel) {
        state?.getSelectedAnnotation(post)
    }
    //MARK: 2.좌표 기반 마커 표시
    func getPostsAtLocation(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        Task {
            do {
                let result = try await usecase.getPost(lat: lat, lon: lon)
                state?.getPosts(result)
            } catch {
                print(error,"error")
            }
        }
    }
    
    func updatePosition(_ newPosition: MapCameraPosition) {
        state?.updatePosition(newPosition)
    }
    //
    func startWalk() {
        print(#function)
        state?.resetCount()
        state?.setTimerOn(true)
        state?.startLocationTracking()
    }
    
    func stopWalk() {
        print(#function)
        state?.setTimerOn(false)
        state?.stopLocationTracking()
    }
    
    func incrementTimer() {
        state?.incrementCount()
    }
    
    func showAlert() {
        state?.setAlert(true)
    }
    
    func closeAlert() {
        state?.setAlert(false)
    }
  
    //설정으로 이동
    func openAppSettings() {
        if let appSettingURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettingURL) {
                UIApplication.shared.open(appSettingURL)
            }
        }
    }
  
    //지도 캡처
    func setSnapshotOptions(coordinates: [CLLocationCoordinate2D]) -> MKMapSnapshotter.Options {
        let options = MKMapSnapshotter.Options()
        let filter: MKPointOfInterestFilter = .excludingAll //모든 point of interest가 안보이도록

        //1.경로 중심 좌표 가져오기
        guard let center = getRouteCenterCoordinate(coordinates: coordinates) else { return options }
        //2.경로 전체를 포함하는 region 갱성
        let region = makeRouteSizeRegion(center: center, coordinates: coordinates)
        
        options.pointOfInterestFilter = filter
        options.size = CGSize(width: 400, height: 250)
        options.region = region
        options.scale = UIScreen.main.scale
        
        return options
    }
  
    //경로 좌표 중심값
    func getRouteCenterCoordinate(coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D? {
        guard coordinates.isEmpty == false || coordinates.count >= 1 else { return nil }
        
        var centerLat: CLLocationDegrees = 0
        var centerLon: CLLocationDegrees = 0
        
        for coordinate in coordinates {
            centerLat += coordinate.latitude
            centerLon += coordinate.longitude
        }
        
        centerLat /= Double(coordinates.count)
        centerLon /= Double(coordinates.count)
        
        return CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
    }
  
    //최대, 최소 위경도 구해서 MKCoordinateRegion 생성
    func makeRouteSizeRegion(center: CLLocationCoordinate2D, coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        let minLatitude = coordinates.min(by: { $0.latitude < $1.latitude })?.latitude ?? 0
        let maxLatitude = coordinates.max(by: { $0.latitude < $1.latitude })?.latitude ?? 0
        let minLongitude = coordinates.min(by: { $0.longitude < $1.longitude })?.longitude ?? 0
        let maxLongitude = coordinates.max(by: { $0.longitude < $1.longitude })?.longitude ?? 0
        
        // 경로의 범위 계산
        var latDelta = (maxLatitude - minLatitude) * 2
        var lonDelta = (maxLongitude - minLongitude) * 2
        
        // 최소값 설정 (약 200미터를 의미)
       let minDelta: CLLocationDegrees = 0.002
       latDelta = max(latDelta, minDelta)
       lonDelta = max(lonDelta, minDelta)
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        return MKCoordinateRegion(center: center, span: span)
    }
  
    //이미지 가져오기
    func setRouteImage(route coordinates: [CLLocationCoordinate2D]) async {
        guard !coordinates.isEmpty else { return }
        
        let options = setSnapshotOptions(coordinates: coordinates)
        let snapShotter = MKMapSnapshotter(options: options)
        
        return await withCheckedContinuation { continuation in
            snapShotter.start { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    continuation.resume()
                    return
                }
                
                let mapImage = snapshot.image
                //지도 이미지에 경로 그리기
                let routeOverlayMapImage = UIGraphicsImageRenderer(size: mapImage.size).image { _ in
                    mapImage.draw(at: .zero)
                    let points = coordinates.map { snapshot.point(for: $0) }
                    let path = UIBezierPath()
                    path.move(to: points.first ?? CGPoint(x: 0, y: 0))
                    
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                    
                    path.lineWidth = 5
                    UIColor((self.state?.getPolylineColor())!).setStroke()
                    path.stroke()
                }
                //캡처된 이미지를 MapState에 저장
                self.state?.saveCapturedRouteImage(routeOverlayMapImage)
                continuation.resume()
            }
        }
    }
    
    func startBackgroundTimer() {
        state?.startBackgroundTimer()
    }
    
    func stopBackgroundTimer() {
        state?.stopTimer()
    }
    //MARK: 1-2새로고침 시 중심 좌표 전달 완료
    func getCenter(_ region: MKCoordinateRegion) {
        state?.getCenter(region)
    }
}

class mockUseCase: MapUseCase {
    func getPost(lat: Double, lon: Double) async throws -> ([PostModel]) {
        let mock = [// CommunityCategoryType의 테스트용 값
            PostModel(
                postID: "test123",
                created: "2024-11-21T12:00:00Z",
                category: .walkCertification,
                title: "Test Post",
                price: 10000,
                content: "This is a test content for the PostModel.",
                creator: UserModel(
                    userID: "user123",
                    nick: "TestUser",
                    profileImage: "https://example.com/profile.jpg"
                ),
                files: ["https://example.com/image1.jpg", "https://example.com/image2.jpg"],
                likes: ["user456", "user789"],
                views: 123,
                hashTags: ["#test", "#swift", "#example"],
                comments: [
                    CommentModel(commentID: "comment1", content: "content1", createdAt: "createdAt", creator: UserModel.init(userID: "user1", nick: "nick1", profileImage: "profileImage1"))
                ],
                geolocation: GeolocationModel(
                    lat: 37.518820573402,
                    lon: 126.89986969097
                ),
                distance: 1.23)
        ]
        return [mock.first!]
    }//위치에 따른 포스트 조회
}
