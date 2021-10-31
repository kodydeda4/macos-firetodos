//
//  UserState.swift
//  Todos
//
//  Created by Kody Deda on 10/26/21.
//

import ComposableArchitecture
import Firebase

struct UserState: Equatable {
  var user: User?
  var todosList = TodoListState()
  var alert: AlertState<UserAction>?
}

enum UserAction: Equatable {
  case todosList(TodoListAction)
  case signOut
}

struct UserEnvironment {
  let client: TodosClient
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
      if subaction == .signOutButtonTapped {
        return Effect(value: .signOut)
      }
      return .none
      
    case .signOut:
      return .none
    }
  }
)

extension Store where State == UserState, Action == UserAction {
  static let `default` = Store(
    initialState: .init(),
    reducer: userReducer,
    environment: UserEnvironment(
      client: .firestore,
      scheduler: .main
    )
  )
}
