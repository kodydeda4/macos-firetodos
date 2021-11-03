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

  // actions
  case attachListener
  case createTodo
  case removeTodo(TodoState)
  case updateTodo(TodoState)
  case clearCompleted
  
  // results
  case didFetchTodos(Result<[TodoState], APIError>)
  case didUpdateRemote(Result<Never, APIError>)
  
  // alerts
  case dismissAlert
  case createClearCompletedAlert
}

struct TodoListEnvironment {
  let todosClient: TodosClient
  let scheduler: AnySchedulerOf<DispatchQueue>
}

let todoListReducer = Reducer<TodoListState, TodoListAction, TodoListEnvironment>.combine(
  todoReducer.forEach(
    state: \.todos,
    action: /TodoListAction.todos(id:action:),
    environment: { _ in () }
  ),
  Reducer { state, action, environment in
    struct EffectID: Hashable {}
    
    switch action {
      
    case let .todos(id, .deleteButonTapped):
      return Effect(value: .removeTodo(state.todos[id: id]!))
      
    case let .todos(id, _):
      return Effect(value: .updateTodo(state.todos[id: id]!))
      
    // actions
    case .attachListener:
      return environment.todosClient.attachListener()
        .receive(on: environment.scheduler)
        .catchToEffect()
        .cancellable(id: EffectID())
        .map(TodoListAction.didFetchTodos)
            
    case .createTodo:
      return environment.todosClient.create()
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.didUpdateRemote)
      
    case let .removeTodo(todo):
      return environment.todosClient.delete(todo)
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.didUpdateRemote)

    case let .updateTodo(todo):
      return environment.todosClient.update(todo)
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.didUpdateRemote)
      
    case .clearCompleted:
      return environment.todosClient.deleteX(state.todos.filter(\.done))
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.didUpdateRemote)
      
    // alerts
    case .dismissAlert:
      state.alert = nil
      return .none
      
    case .createClearCompletedAlert:
      state.alert = AlertState(
        title: TextState("Clear completed?"),
        primaryButton: .default(TextState("Okay"), action: .send(.clearCompleted)),
        secondaryButton: .cancel(TextState("Cancel"))
      )
      return .none
      
    // results
    case let .didFetchTodos(.success(todos)):
      state.todos = IdentifiedArray(uniqueElements: todos)
      return .none
      
    case let .didFetchTodos(.failure(error)):
      state.alert = AlertState(title: TextState("\(error.localizedDescription)"))
      return .none
      
    case let .didUpdateRemote(.failure(error)):
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
