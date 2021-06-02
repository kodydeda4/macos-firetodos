//
//  AuthenticationView.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture

struct AuthenticationView: View {
    let store: Store<Authentication.State, Authentication.Action>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                VStack {
                    TextField("Email", text: viewStore.binding(get: \.email, send: Authentication.Action.updateEmail))
                    TextField("Password", text: viewStore.binding(get: \.password, send: Authentication.Action.updatePassword))
                    
                    Text("Wrong password. Try again or click Forgot password to reset it.")
                        .opacity(viewStore.attempted ? 1 : 0)
                        .foregroundColor(.red)
                    
                    Button("Login with email") { viewStore.send(.loginButtonTapped) }
                    
                    Button("Sign In Anonymously") { viewStore.send(.signInAnonymouslyButtonTapped) }
                }
                .padding(60)
            }
        }
    }
}

struct Authentication_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(store: Authentication.defaultStore)
    }
}
