//
//  Root.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import ComposableArchitecture

enum RootState: Equatable {
  case authentication(Authentication.State)
  case user(UserState)
  
}

enum RootAction: Equatable {
  case authentication(Authentication.Action)
  case user(UserAction)
}

struct RootEnvironment {
  //var client: UserClient
}

let rootReducer = Reducer<RootState, RootAction, RootEnvironment>.combine(
  Authentication.reducer.pullback(
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
        
      default:
        break
      }
      return .none
      
//    case let .todosList(subaction):
//      switch subaction {
//
//      case .confirmSignOutAlert:
//        return Effect(value: .authentication(.signOut))
//
//      default:
//        break
      
    default:
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
