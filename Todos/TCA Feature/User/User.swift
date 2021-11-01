//
//  UserState.swift
//  Todos
//
//  Created by Kody Deda on 10/26/21.
//

import ComposableArchitecture
import Firebase

struct UserState: Equatable {
  var user: User
  var isPremiumUser = false
  var todosList = TodoListState()
  var alert: AlertState<UserAction>?
}

enum UserAction: Equatable {
  case todosList(TodoListAction)
  case signout
  case createSignoutAlert
  case dismissAlert
  case buyPremiumButtonTapped
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
      
    case .todosList:
      return .none
      
    case .createSignoutAlert:
      state.alert = AlertState(
        title: TextState("Are you sure?"),
        primaryButton: .default(TextState("Confirm"), action: .send(.signout)),
        secondaryButton: .cancel(TextState("Cancel"))
      )
      return .none
      
    case .signout:
      return .none
      
    case .dismissAlert:
      state.alert = nil
      return .none
      
    case .buyPremiumButtonTapped:
      return .none
    }
  }
).debug()

extension Store where State == UserState, Action == UserAction {
  static let `default` = Store(
    initialState: .init(user: Auth.auth().currentUser!),
    reducer: userReducer,
    environment: UserEnvironment(
      client: .live,
      scheduler: .main
    )
  )
}
