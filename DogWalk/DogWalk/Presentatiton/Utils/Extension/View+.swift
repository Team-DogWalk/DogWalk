//
//  View+.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import SwiftUI

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func tabBarHidden(_ hidden: Bool) -> some View {
        self.toolbar(hidden ? .hidden : .visible, for: .tabBar)
    }
}
