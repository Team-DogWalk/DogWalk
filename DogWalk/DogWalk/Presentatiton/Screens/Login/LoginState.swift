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
            let future = try await network.request(target: .user(.emailLogin(body: body)), of: OAuthLoginDTO.self)
            
            future
                .sink { result in
                    switch result {
                    case .finished:
                        print("✨ 로그인 성공")
                    case .failure(let error):
                        print("🚨 로그인 실패", error)
                    }
                } receiveValue: { [weak self] data in
                    let domain = data.toDomain()
                    // 로그인 성공 응답값을 UserDefaults에 저장
                    UserManager.shared.userID = domain.userID
                    UserManager.shared.userNick = domain.nick
                    UserManager.shared.acess = domain.accessToken
                    UserManager.shared.refresh = domain.refreshToken
                    UserManager.shared.isUser = true
                    self?.isLoginDone = true
                }
                .store(in: &cancellables)
        } catch {
            print("로그인 요청 실패", error)
        }
    }
}

