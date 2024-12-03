//
//  ContentView.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appCoordinator: MainCoordinator

    var body: some View {
        CoordinatorView()
            .environmentObject(appCoordinator)
    }
}

#Preview {
    ContentView()
}
