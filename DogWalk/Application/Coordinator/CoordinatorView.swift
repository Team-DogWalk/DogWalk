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
            appCoordinator.build(.tab)
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

