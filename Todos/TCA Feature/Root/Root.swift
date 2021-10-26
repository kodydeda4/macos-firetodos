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
  //var client: UserClient
}

let rootReducer = Reducer<RootState, RootAction, RootEnvironment>.combine(
  authenticationReducer.pullback(
    state: /RootState.authentication,
    action: /RootAction.authentication,
    environment: { _ in .init() }
  ),
  userReducer.pullback(
    state: /RootState.user,
    action: /RootAction.user,
    environment: { _ in .init()}
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
        
      case .confirmSignOutAlert:
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
  static let defaultStore = Store(
    initialState: .authentication(
      .init(
        email: "test@email.com",
        password: "123123"
      )),
    reducer: rootReducer,
    environment: .init()
    //    environment: .init(client: .live)
  )
}
