//
//  LoginView.swift
//  DogWalk
//
//  Created by junehee on 11/11/24.
//

import SwiftUI
import Combine

struct LoginView: View {
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    @EnvironmentObject var appCoordinator: MainCoordinator
    
    @StateObject var container: Container<LoginIntentProtocol, LoginStateProtocol>
    private var state: LoginStateProtocol { container.state }
    private var intent: LoginIntentProtocol { container.intent }
    
    private let network = NetworkManager()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: TestLoginAccount에 여러가지 계정 만들어두었으니 사용하실 때 참고하세요!
    @State private var idText: String = TestLoginAccount.junehee.idString
    @State private var pwText: String = TestLoginAccount.junehee.pwString
}

extension LoginView {
    static func build() -> some View {
        let state = LoginState()
        let intent = LoginIntent(state: state)
        let container = Container(
            intent: intent as LoginIntentProtocol,
            state: state as LoginStateProtocol,
            modelChangePublisher: state.objectWillChange
        )
        let view = LoginView(container: container)
        return view
    }
}

extension LoginView {
    var body: some View {
        VStack {
            TextField("ID", text: $idText)
            TextField("Password", text: $pwText)
                .padding(.bottom, 40)
            CommonButton(width: width - 20, height: 60,
                         cornerradius: 20, backColor: .primaryGreen,
                         text: "로그인", textFont: .pretendardBold18)
            .wrapToButton {
                await intent.onAppearTigger(id: idText, pw: pwText)
            }
        }
        .padding(.horizontal)
        .onChange(of: state.isLoginDone) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.async {
                    appCoordinator.push(.tab)
                }
            }
        }
    }
}

