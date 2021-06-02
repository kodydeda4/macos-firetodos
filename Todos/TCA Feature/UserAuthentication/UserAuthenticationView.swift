//
//  UserAuthenticationView.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture

struct UserAuthenticationView: View {
    let store: Store<UserAuthentication.State, UserAuthentication.Action>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                VStack {
                    TextField("Email", text: viewStore.binding(get: \.email, send: UserAuthentication.Action.updateEmail))
                    TextField("Password", text: viewStore.binding(get: \.password, send: UserAuthentication.Action.updatePassword))
                    
                    Text("Wrong password. Try again or click Forgot password to reset it.")
                        .opacity(viewStore.failedLoginAttempt ? 1 : 0)
                        .foregroundColor(.red)
                    
                    Button("Login with email") { viewStore.send(.loginButtonTapped) }
                }
                .padding(60)
            }
        }
    }
}

struct UserAuthentication_Previews: PreviewProvider {
    static var previews: some View {
        UserAuthenticationView(store: UserAuthentication.defaultStore)
    }
}
