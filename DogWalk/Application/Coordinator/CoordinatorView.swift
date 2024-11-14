//
//  CoordinatorView.swift
//  DogWalk
//
//  Created by 김윤우 on 11/8/24.
//

import SwiftUI

struct CoordinatorView: View {
    // @StateObject var appCoordinator: MainCoordinator = MainCoordinator()
    @EnvironmentObject var appCoordinator: MainCoordinator
    
    var body: some View {
        NavigationStack(path: $appCoordinator.path) {
<<<<<<< HEAD
            appCoordinator.build(.tab)
=======
            appCoordinator.build(.home)
>>>>>>> 6a18676 (Refactor: 홈뷰 구조 변경 및 배너, 인기 산책 인증 스크롤뷰 인디케이터 삭제)
                .navigationDestination(for: Screen.self) { screen in
                    appCoordinator.build(screen)
                }
                .sheet(item: $appCoordinator.sheet) { sheet in
                    appCoordinator.build(sheet)
                }
                .fullScreenCover(item: $appCoordinator.fullScreenCover) { fullScreenCover in
                    appCoordinator.build(fullScreenCover)
                }
        }
        .environmentObject(appCoordinator)
    }
}

#Preview {
    CoordinatorView()   
}

