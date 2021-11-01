//
//  UserAuthentication.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import ComposableArchitecture
import AuthenticationServices
import Firebase

struct AuthenticationState: Equatable {
  @BindableState var email = String()
  @BindableState var password = String()
  var error: APIError?
  var route: Route = .login
  var alert: AlertState<AuthenticationAction>? = nil
  
  enum Route {
    case login
    case signup
  }
}

enum AuthenticationAction: BindableAction, Equatable {
  case binding(BindingAction<AuthenticationState>)
  case updateRoute(AuthenticationState.Route)
  case createSignupAlert
  case alertDismissed
  
  case signInAnonymously
  case signInWithEmail
  case signInWithApple(SignInWithAppleToken)
  case signInResult(Result<Firebase.User, APIError>)
  case signUpWithEmail
}

struct AuthenticationEnvironment {
  let client: AuthClient
  let scheduler: AnySchedulerOf<DispatchQueue>
}

let authenticationReducer = Reducer<
  AuthenticationState,
  AuthenticationAction,
  AuthenticationEnvironment
> { state, action, environment in
  
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
    
  case let .signInWithApple(credential):
    return environment.client.signInApple(credential)
      .receive(on: environment.scheduler)
      .catchToEffect()
      .map(AuthenticationAction.signInResult)
    
  case .signInResult(.success):
    return .none
    
  case let .signInResult(.failure(error)):
    state.error = error
    return .none
    
  case .signUpWithEmail:
    return .none
    
  case let .updateRoute(route):
    state.route = route
    return .none
    
  case .alertDismissed:
    state.alert = nil
    return .none
    
  case .createSignupAlert:
    state.alert = AlertState(
      title: TextState("Signup Alert"),
      primaryButton: .default(TextState("Okay"), action: .send(.alertDismissed)),
      secondaryButton: .cancel(TextState("Cancel"))
    )
    return .none
  }
}
.binding()

extension Store where State == AuthenticationState, Action == AuthenticationAction {
  static let `default` = Store(
    initialState: .init(),
    reducer: authenticationReducer,
    environment: AuthenticationEnvironment(
      client: .live,
      scheduler: .main
    )
  )
}
