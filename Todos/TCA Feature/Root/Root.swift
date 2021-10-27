//
//  Root.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import ComposableArchitecture

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
    environment: { AuthenticationEnvironment(client: $0.authClient, scheduler: $0.scheduler) }
  ),
  userReducer.pullback(
    state: /RootState.user,
    action: /RootAction.user,
    environment: { UserEnvironment(client: $0.todosClient, scheduler: $0.scheduler) }
  ),
  Reducer { state, action, environment in
    switch action {
      
    case let .authentication(subaction):
      switch subaction {
        
      case .signInResult(.success):
        state = .user(.init())
        return .none
        
      default:
        break
      }
      return .none
      
    case let .user(subaction):
      switch subaction {
        
      case .signOut:
        state = .authentication(.init())
        return .none
        
      default:
        break
      }
      return .none
    }
  }
)

extension RootState {
  static let defaultStore: Store<RootState, RootAction> = .init(
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
