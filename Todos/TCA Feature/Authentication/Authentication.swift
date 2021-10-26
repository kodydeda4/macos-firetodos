//
//  UserAuthentication.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import ComposableArchitecture
import AuthenticationServices

struct AuthenticationState: Equatable {
  @BindableState var email = String()
  @BindableState var password = String()
  var error: FirebaseError?
}

enum AuthenticationAction: BindableAction, Equatable {
  case binding(BindingAction<AuthenticationState>)
  case signInAnonymously
  case signInWithEmail
  case signInWithApple(id: ASAuthorizationAppleIDCredential, nonce: String)
  case signInResult(Result<Bool, FirebaseError>)
}

struct AuthenticationEnvironment {
  let client: UserClient

  var signIn: Effect<AuthenticationAction, Never> {
    Firebase.signIn()
      .map(AuthenticationAction.signInResult)
      .eraseToEffect()
  }
  
  func signIn(
    _ email: String,
    _ password: String
  ) -> Effect<AuthenticationAction, Never> {
    Firebase.signIn(with: email, and: password)
      .map(AuthenticationAction.signInResult)
      .eraseToEffect()
  }
  
  func signIn(
    _ appleID: ASAuthorizationAppleIDCredential,
    _ nonce: String
  ) -> Effect<AuthenticationAction, Never> {
    Firebase.signIn(using: appleID, and: nonce)
      .map(AuthenticationAction.signInResult)
      .eraseToEffect()
  }
}

let authenticationReducer = Reducer<AuthenticationState, AuthenticationAction, AuthenticationEnvironment> { state, action, environment in
  
  switch action {
    
  case .binding:
    return .none
    
  case .signInAnonymously:
    return environment.signIn
    
  case .signInWithEmail:
    return environment.signIn(state.email, state.password)
    
  case let .signInWithApple(appleID, nonce):
    return environment.signIn(appleID, nonce)
    
  case .signInResult(.success):
    return .none
    
  case let .signInResult(.failure(error)):
    state.error = error
    return .none
  }
}
.binding()

extension AuthenticationState {
  static let defaultStore = Store(
    initialState: .init(),
    reducer: authenticationReducer,
    environment: .init(client: .live)
  )
}
