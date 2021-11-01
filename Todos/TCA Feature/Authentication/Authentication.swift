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
  case dismissAlert  
  case signInAnonymously
  case signInWithEmail
  case signInWithApple(SignInWithAppleToken)
  case signInResult(Result<Firebase.User, APIError>)
  case signUpWithEmail
  case signupResult(Result<Firebase.User, APIError>)
}

struct AuthenticationEnvironment {
  let authClient: AuthClient
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
    return environment.authClient.signInAnonymously()
      .receive(on: environment.scheduler)
      .catchToEffect()
      .map(AuthenticationAction.signInResult)
    
  case .signInWithEmail:
    return environment.authClient.signInEmailPassword(state.email,state.password)
      .receive(on: environment.scheduler)
      .catchToEffect()
      .map(AuthenticationAction.signInResult)
    
  case let .signInWithApple(credential):
    return environment.authClient.signInApple(credential)
      .receive(on: environment.scheduler)
      .catchToEffect()
      .map(AuthenticationAction.signInResult)
    
  case .signInResult(.success):
    return .none
    
  case let .signInResult(.failure(error)):
    state.error = error
    return .none
    
  case let .signupResult(.success(user)):
    print(user)
    return .none
    
  case let .signupResult(.failure(error)):
    state.alert = AlertState(
      title: TextState("\(error.localizedDescription)"),
      primaryButton: .default(TextState("Okay"), action: .send(.dismissAlert)),
      secondaryButton: .cancel(TextState("Cancel"))
    )
    return .none

  case .signUpWithEmail:
    return environment.authClient.signup(state.email, state.password)
      .receive(on: environment.scheduler)
      .catchToEffect()
      .map(AuthenticationAction.signupResult)

  case let .updateRoute(route):
    state.route = route
    state.email = ""
    state.password = ""
    state.alert = nil
    return .none
    
  case .dismissAlert:
    state.alert = nil
    return .none
    
  case .createSignupAlert:
    state.alert = AlertState(
      title: TextState("Signup Alert"),
      primaryButton: .default(TextState("Okay"), action: .send(.dismissAlert)),
      secondaryButton: .cancel(TextState("Cancel"))
    )
    return .none
  }
}
.binding()
.debug()

extension Store where State == AuthenticationState, Action == AuthenticationAction {
  static let `default` = Store(
    initialState: .init(),
    reducer: authenticationReducer,
    environment: AuthenticationEnvironment(
      authClient: .live,
      scheduler: .main
    )
  )
}
