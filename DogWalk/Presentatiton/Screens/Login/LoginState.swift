//
//  LoginState.swift
//  DogWalk
//
//  Created by junehee on 11/11/24.
//

import Foundation
import Combine

protocol LoginStateProtocol {
    var isLoginDone: Bool { get }
}

protocol LoginActionProtocol: AnyObject {
    func login(id: String, pw: String) async
}

@Observable
final class LoginState: LoginStateProtocol, ObservableObject {
    private let network = NetworkManager()
    private var cancellables = Set<AnyCancellable>()
    
    var isLoginDone: Bool = false
}

extension LoginState: LoginActionProtocol {
    func login(id: String, pw: String) async {
        print("로그인 요청 실행")
        do {
            let body = EmailLoginBody(email: id, password: pw)
            let domain = try await network.requestDTO(target: .user(.emailLogin(body: body)), of: OAuthLoginDTO.self).toDomain()
            UserManager.shared.userID = domain.userID
            UserManager.shared.userNick = domain.nick
            UserManager.shared.acess = domain.accessToken
            UserManager.shared.refresh = domain.refreshToken
            UserManager.shared.isUser = true
            isLoginDone = true

        } catch {
            print("로그인 요청 실패", error)
        }
    }
}

