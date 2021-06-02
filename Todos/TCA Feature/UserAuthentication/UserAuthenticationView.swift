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
                }
            }
            .toolbar {
                ToolbarItem {
                    Button("Login") {
                        viewStore.send(.loginButtonTapped)
                    }
                }
            }
        }
    }
}

struct UserAuthentication_Previews: PreviewProvider {
    static var previews: some View {
        UserAuthenticationView(store: UserAuthentication.defaultStore)
    }
}
