//
//  Container.swift
//  DogWalk
//
//  Created by junehee on 10/29/24.
//

import SwiftUI
import Combine

final class Container<Intent, state>: ObservableObject {
    let intent: Intent // Input
    let state: state // Output
    
    private var cancellable: Set<AnyCancellable> = []
    
    init(intent: Intent, state: state, modelChangePublisher: ObjectWillChangePublisher) {
        self.intent = intent
        self.state = state
        
        modelChangePublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: objectWillChange.send)
            .store(in: &cancellable)
    }
}

