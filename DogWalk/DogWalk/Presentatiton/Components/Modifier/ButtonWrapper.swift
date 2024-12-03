//
//  ButtonWrapper.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import SwiftUI

private struct ButtonWrapper: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        Button(action: action, label: { content })
    }
}

extension View {
    func wrapToButton(action: @escaping () -> Void) -> some View {
        modifier(ButtonWrapper(action: action))
    }
    
    // 비동기
    func wrapToButton(asyncAction: @escaping () async -> Void) -> some View {
        let action = {
            DispatchQueue.main.async {
                Task {
                    await asyncAction()
                }
            }
        }
        return modifier(ButtonWrapper(action: action))
    }
}
