//
//  CustomTabView.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var coordinator: MainCoordinator // Coordinator 주입

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            coordinator.build(.home) // 홈 화면 생성
                .tabItem {
                    Image.asWalk
                        .renderingMode(.template)
                    Text("홈")
                }
                .tag(Tab.home)

            coordinator.build(.map) // 산책하기 화면 생성
                .tabItem {
                    Image.asWalk
                        .renderingMode(.template)
                    Text("산책하기")
                }
                .tag(Tab.dogWalk)

            coordinator.build(.community) // 커뮤니티 화면 생성
                .tabItem {
                    Image.asWalk
                        .renderingMode(.template)
                    Text("커뮤니티")
                }
                .tag(Tab.community)

            coordinator.build(.chatting) // 멍톡 화면 생성
                .tabItem {
                    Image.asWalk
                        .renderingMode(.template)
                    Text("멍톡")
                }
                .tag(Tab.chatting)
        }
        .tint(Color.primaryGreen)
        .navigationBarBackButtonHidden()
    }
}
