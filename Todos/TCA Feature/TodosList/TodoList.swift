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
  var error: APIError?
  var alert: AlertState<TodoListAction>?
}

enum TodoListAction: Equatable {
  case todos(id: TodoState.ID, action: TodoAction)
  case fetchTodos
  case createTodo
  case removeTodo(TodoState)
  case updateTodo(TodoState)
  case clearCompleted
  case signOutButtonTapped
  case fetchTodosResult(Result<[TodoState], APIError>)
  case updateFirestoreResult(Result<Bool, APIError>)
}

struct TodoListEnvironment {
  let client: TodosClient
  let scheduler: AnySchedulerOf<DispatchQueue>
}

let todoListReducer = Reducer<TodoListState, TodoListAction, TodoListEnvironment>.combine(
  todoReducer.forEach(
    state: \.todos,
    action: /TodoListAction.todos(id:action:),
    environment: { _ in () }
  ),
  Reducer { state, action, environment in
    struct CancelID: Hashable {}
    
    switch action {
      
    case let .todos(id, action):
      let todo = state.todos[id: id]!
      
      return action == .deleteButonTapped
      ? Effect(value: .removeTodo(todo))
      : Effect(value: .updateTodo(todo))
      
    case .fetchTodos:
      return environment.client.fetch()
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.fetchTodosResult)
      
    case .createTodo:
      return environment.client.create()
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.updateFirestoreResult)
      
    case let .removeTodo(todo):
      return environment.client.delete(todo)
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.updateFirestoreResult)
      
    case let .updateTodo(todo):
      return environment.client.update(todo)
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.updateFirestoreResult)
      
    case .clearCompleted:
      return environment.client.deleteX(state.todos.filter(\.done))
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.updateFirestoreResult)
      
    case let .fetchTodosResult(.success(todos)):
      state.todos = IdentifiedArray(uniqueElements: todos)
      return .none
      
    case let .fetchTodosResult(.failure(error)):
      state.error = error
      return .none
      
    case .updateFirestoreResult(.success):
      return .none
      
    case let .updateFirestoreResult(.failure(error)):
      state.error = error
      return .none
      
    case .signOutButtonTapped:
      return .none
    }
  }
)

extension Store where State == TodoListState, Action == TodoListAction {  
  static let `default` = Store(
    initialState: .init(),
    reducer: todoListReducer,
    environment: TodoListEnvironment(
      client: .live,
      scheduler: .main
    )
  )
}
