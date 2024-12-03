//
//  LoginIntent.swift
//  DogWalk
//
//  Created by junehee on 11/11/24.
//

import Foundation

protocol LoginIntentProtocol {
    func onAppearTigger(id: String, pw: String) async
}

final class LoginIntent {
    private weak var state: LoginActionProtocol?
    
    init(state: LoginActionProtocol) {
        self.state = state
    }
}

extension LoginIntent: LoginIntentProtocol {
    func onAppearTigger(id: String, pw: String) async {
        await state?.login(id: id, pw: pw)
    }
}
