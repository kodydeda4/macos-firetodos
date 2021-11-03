//
//  TodosList.swift
//  Todos
//
//  Created by Kody Deda on 6/1/21.
//

import Combine
import ComposableArchitecture
import IdentifiedCollections

struct TodoListState: Equatable {
  var todos: IdentifiedArrayOf<TodoState> = []
  var alert: AlertState<TodoListAction>?
}

enum TodoListAction: Equatable {
  case todos(id: TodoState.ID, action: TodoAction)
  case fetch
  case create
  case clearCompleted
  case createAlert
  case dismissAlert
  case didFetch(Result<[TodoState], APIError>)
  case didCreate(Result<Never, APIError>)
  case didClearCompleted(Result<Never, APIError>)
}

struct TodoListEnvironment {
  let todosClient: TodosClient
  let scheduler: AnySchedulerOf<DispatchQueue>
}

let todoListReducer = Reducer<TodoListState, TodoListAction, TodoListEnvironment>.combine(
  todoReducer.forEach(
    state: \.todos,
    action: /TodoListAction.todos(id:action:),
    environment: { .init(todosClient: $0.todosClient, scheduler: $0.scheduler) }
  ),
  Reducer { state, action, environment in
    struct EffectID: Hashable {}
    
    switch action {
    
    case .todos:
      return .none
      
    case .fetch:
      return environment.todosClient.fetch()
        .receive(on: environment.scheduler)
        .catchToEffect()
        .cancellable(id: EffectID())
        .map(TodoListAction.didFetch)
            
    case .create:
      return environment.todosClient.create()
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.didCreate)
      
    case .clearCompleted:
      return environment.todosClient.removeX(state.todos.filter(\.done))
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.didClearCompleted)
      
    case .dismissAlert:
      state.alert = nil
      return .none
      
    case .createAlert:
      state.alert = AlertState(
        title: TextState("Clear completed?"),
        primaryButton: .default(TextState("Okay"), action: .send(.clearCompleted)),
        secondaryButton: .cancel(TextState("Cancel"))
      )
      return .none
      
    case let .didFetch(.success(todos)):
      state.todos = IdentifiedArray(uniqueElements: todos)
      return .none
      
    case let .didFetch(.failure(error)):
      state.alert = AlertState(title: TextState("\(error.localizedDescription)"))
      return .none
      
    case let .didCreate(.failure(error)):
      state.alert = AlertState(title: TextState("\(error.localizedDescription)"))
      return .none
      
    case let .didClearCompleted(.failure(error)):
      state.alert = AlertState(title: TextState("\(error.localizedDescription)"))
      return .none
    }
  }
)

extension Store where State == TodoListState, Action == TodoListAction {  
  static let `default` = Store(
    initialState: .init(),
    reducer: todoListReducer,
    environment: TodoListEnvironment(
      todosClient: .live,
      scheduler: .main
    )
  )
}
