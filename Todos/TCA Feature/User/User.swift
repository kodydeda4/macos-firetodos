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
  case signOut
}

struct UserEnvironment {
  let client: UserClient
  let scheduler: AnySchedulerOf<DispatchQueue>
}

let userReducer = Reducer<UserState, UserAction, UserEnvironment>.combine(
  todoListReducer.pullback(
    state: \.todosList,
    action: /UserAction.todosList,
    environment: { .init(client: $0.client, scheduler: $0.scheduler) }
  ),
  
  Reducer { state, action, environment in
    
    switch action {
      
    case let .todosList(subaction):
      return .none
      
    case .signOut:
      return .none
    }
  }
)

extension UserState {
  static let defaultStore = Store(
    initialState: .init(),
    reducer: userReducer,
    environment: .init(client: .live, scheduler: .main)
  )
}
