//
//  Root.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import ComposableArchitecture

enum RootState: Equatable {
  case authentication(Authentication.State)
  case todosList(TodosList.State)
}

enum RootAction: Equatable {
  case authentication(Authentication.Action)
  case todosList(TodosList.Action)
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
  TodosList.reducer.pullback(
    state: /RootState.todosList,
    action: /RootAction.todosList,
    environment: { _ in .init() }
  ),
  Reducer { state, action, environment in
    switch action {
      
    case let .authentication(subaction):
      switch subaction {
        
      case .signInResult(.success):
        state = .todosList(.init())
        
      default:
        break
      }
      return .none
      
    case let .todosList(subaction):
      switch subaction {
        
      case .confirmSignOutAlert:
        return Effect(value: .authentication(.signOut))
        
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
