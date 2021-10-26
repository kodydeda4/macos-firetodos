//
//  AuthenticationView.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture
import AuthenticationServices

struct AuthenticationView: View {
  let store: Store<AuthenticationState, AuthenticationAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      Form {
        Text("Login")
          .font(.largeTitle)
        
        SignInWithAppleButton() {
          viewStore.send(.signInWithApple(id: $0, nonce: $1))
        }
        
        TextField("Email", text: viewStore.binding(\.$email))
        SecureField("Password", text: viewStore.binding(\.$password))

        Button("Login") {
          viewStore.send(.signInWithEmail)
        }
        
        Button("Continue as Guest") {
          viewStore.send(.signInAnonymously)
        }
      }
      .navigationTitle("")
    }
  }
}

struct Authentication_Previews: PreviewProvider {
  static var previews: some View {
    AuthenticationView(store: AuthenticationState.defaultStore)
  }
}

