//
//  UserState.swift
//  Todos
//
//  Created by Kody Deda on 10/26/21.
//

import ComposableArchitecture

struct UserState: Equatable {
  var todosList = TodoListState()
  var alert: AlertState<UserAction>?
}

enum UserAction: Equatable {
  case todosList(TodoListAction)
  
  // alerts
  case createSignOutAlert
  case confirmSignOutAlert
  case dismissSignOutAlert
}

struct UserEnvironment {
  
}

let userReducer = Reducer<UserState, UserAction, UserEnvironment>.combine(
  todoListReducer.pullback(
    state: \.todosList,
    action: /UserAction.todosList,
    environment: { _ in .init() }
  ),

  Reducer { state, action, environment in
  
    switch action {
    
    case let .todosList(subaction):
      //...
      return .none
      
      // alerts
    case .createSignOutAlert:
      state.alert = AlertState(title: TextState("Sign out?"))
      return .none
      
    case .dismissSignOutAlert:
      state.alert = nil
      return .none
      
    case .confirmSignOutAlert:
      return .none
      
    }
  }
)

extension UserState {
  static let defaultStore = Store(
    initialState: .init(),
    reducer: userReducer,
    environment: .init()
  )
}
