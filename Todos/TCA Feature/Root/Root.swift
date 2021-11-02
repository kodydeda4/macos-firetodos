//
//  Root.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import ComposableArchitecture
import Firebase

enum RootState: Equatable {
  case authentication(AuthenticationState)
  case user(UserState)
}

enum RootAction: Equatable {
  case authentication(AuthenticationAction)
  case user(UserAction)
}

struct RootEnvironment {
  let authClient: AuthClient
  let todosClient: TodosClient
  let scheduler: AnySchedulerOf<DispatchQueue>
}

let rootReducer = Reducer<RootState, RootAction, RootEnvironment>.combine(
  authenticationReducer.pullback(
    state: /RootState.authentication,
    action: /RootAction.authentication,
    environment: { .init(authClient: $0.authClient, scheduler: $0.scheduler) }
  ),
  userReducer.pullback(
    state: /RootState.user,
    action: /RootAction.user,
    environment: { .init(todosClient: $0.todosClient, scheduler: $0.scheduler) }
  ),
  Reducer { state, action, environment in
    switch action {
      
    case let .authentication(.signInResult(.success(user))):
      state = .user(.init(user: user))
      return .none
      
    case .user(.signout):
      state = .authentication(.init())
      return .none
      
    case .authentication, .user:
      return .none
    }
  }
).debug()

extension Store where State == RootState, Action == RootAction {
  static let `default` = Store(
    initialState: .authentication(
      AuthenticationState.init(
        email: "test@email.com",
        password: "123123"
      )),
    reducer: rootReducer,
    environment: RootEnvironment(
      authClient: .live,
      todosClient: .live,
      scheduler: .main
    )
  )
}
