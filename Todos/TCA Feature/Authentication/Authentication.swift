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
  let scheduler: AnySchedulerOf<DispatchQueue>
}

let authenticationReducer = Reducer<AuthenticationState, AuthenticationAction, AuthenticationEnvironment> { state, action, environment in
  
  switch action {
    
  case .binding:
    return .none
    
  case .signInAnonymously:
    return environment.client.signInAnonymously()
      .receive(on: environment.scheduler)
      .catchToEffect()
      .map(AuthenticationAction.signInResult)
    
  case .signInWithEmail:
    return environment.client.signInEmailPassword(state.email,state.password)
      .receive(on: environment.scheduler)
      .catchToEffect()
      .map(AuthenticationAction.signInResult)
    
  case let .signInWithApple(appleID, nonce):
    return environment.client.signInApple(appleID, nonce)
      .receive(on: environment.scheduler)
      .catchToEffect()
      .map(AuthenticationAction.signInResult)
    
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
    environment: .init(client: .live, scheduler: .main)
  )
}
