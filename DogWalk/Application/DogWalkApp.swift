//
//  DogWalkApp.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import SwiftUI
import BackgroundTasks

@main
struct DogWalkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // @StateObject var appDelegate = AppDelegate()
    @StateObject var appCoordinator: MainCoordinator = MainCoordinator()
    
    private var socket: SocketProvider?
    private var access = UserManager.shared.acess
    @State var recentRoomID = UserManager.shared.recentRoomID
    
    init() {
        let appearance = UINavigationBarAppearance()
        // 뒤로 가기 버튼의 텍스트 제거
        appearance.setBackIndicatorImage(UIImage(systemName: "chevron.left"), transitionMaskImage: UIImage(systemName: "chevron.left"))
        appearance.backButtonAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: -1000, vertical: 0) // 텍스트 위치를 화면 밖으로 밀어내기
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        // 전체 내비게이션 바 스타일 설정
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        CoreChatMessageTransformer.register()
        CoreLastChatTransformer.register()
        CoreUserTransformer.register()
        StringArrayTransformer.register()
        
    }
    
    var body: some Scene {
        WindowGroup {
            if access != "" {
                ContentView()
                    .environmentObject(appCoordinator)
                // .environmentObject(appDelegate)
            } else {
                LoginView.build()
                    .environmentObject(appCoordinator)
            }
        }
    }
}

// MARK: - 기본
class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    private var socket: SocketProvider?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.DogWalk2.background.socket", using: nil) { task in
            self.handleDisconnectSocket(task: task as! BGAppRefreshTask)
        }
        return true
    }
    
    func handleDisconnectSocket(task: BGAppRefreshTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let operation = BlockOperation {
            self.socketDisconnect()
        }
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }
        
        queue.addOperation(operation)
    }
    
    func scheduleSocketDisconnectTask(after interval: TimeInterval) {
        let request = BGProcessingTaskRequest(identifier: "com.DogWalk2.background.socket")
        request.earliestBeginDate = Date(timeIntervalSinceNow: interval) // interval 초 후 실행 요청
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Unable to submit task: \(error.localizedDescription)")
        }
    }
    
    func socketDisconnect() {
        let roomID = UserManager.shared.recentRoomID
        if roomID.isEmpty {
            print("Invalid Recent RoomID!")
            return
        }
        let socket = SocketIOManager(roomID: UserManager.shared.recentRoomID)
        socket.disconnect()
    }
}

// MARK: - 시뮬레이터 설정 버전
// class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
//     private var socket: SocketProvider?
//
//     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//         // 디버그 환경에서 백그라운드 태스크 시뮬레이션 설정
//         #if DEBUG
//         if CommandLine.arguments.contains("--simulateBackgroundTask") {
//             BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.DogWalk2.background.socket", using: .main) { task in
//                 self.handleDisconnectSocket(task: task as! BGProcessingTask)
//             }
//         }
//         #else
//         BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.DogWalk2.background.socket", using: .main) { task in
//             self.handleDisconnectSocket(task: task as! BGProcessingTask)
//         }
//         #endif
//         return true
//     }
//
//     func scheduleSocketDisconnectTask(after interval: TimeInterval) {
//         let request = BGProcessingTaskRequest(identifier: "com.DogWalk2.background.socket")
//         request.earliestBeginDate = Date(timeIntervalSinceNow: interval)
//         request.requiresNetworkConnectivity = false
//         request.requiresExternalPower = false
//
//         do {
//             try BGTaskScheduler.shared.submit(request)
//             print("Background task scheduled successfully")
//
//             #if DEBUG
//             // 디버그 환경에서 태스크 시뮬레이션
//             DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
//                 // 백그라운드 태스크 시뮬레이션
//                 self.socketDisconnect()
//             }
//             #endif
//
//         } catch {
//             print("Unable to submit task: \(error.localizedDescription)")
//         }
//     }
//
//     func handleDisconnectSocket(task: BGProcessingTask) {
//         let queue = OperationQueue()
//         queue.maxConcurrentOperationCount = 1
//
//         let operation = BlockOperation {
//             self.socketDisconnect()
//         }
//
//         task.expirationHandler = {
//             queue.cancelAllOperations()
//         }
//
//         operation.completionBlock = {
//             task.setTaskCompleted(success: !operation.isCancelled)
//
//             // 다음 백그라운드 태스크 스케줄링
//             self.scheduleSocketDisconnectTask(after: 60)
//         }
//
//         queue.addOperation(operation)
//     }
//
//     func socketDisconnect() {
//         print("Attempting to disconnect socket...")
//         print("Current roomID:", UserManager.shared.recentRoomID)
//
//         let roomID = UserManager.shared.recentRoomID
//         if roomID.isEmpty {
//             print("Invalid Recent RoomID!")
//             return
//         }
//         let socket = SocketIOManager(roomID: roomID)
//         socket.disconnect()
//         print("Socket disconnected for room:", roomID)
//     }
// }
