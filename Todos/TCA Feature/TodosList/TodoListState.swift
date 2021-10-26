//
//  TodosList.swift
//  Todos
//
//  Created by Kody Deda on 6/1/21.
//

import Combine
import ComposableArchitecture

struct TodoListState: Equatable {
  var todos: IdentifiedArrayOf<TodoState> = []
  var error: FirestoreError?
  var alert: AlertState<TodoListAction>?
}

enum TodoListAction: Equatable {
  case todos(id: TodoState.ID, action: TodoAction)
  
  // firestore
  case fetchTodos
  case createTodo
  case removeTodo(TodoState)
  case updateTodo(TodoState)
  case clearCompleted
  
  // results
  case didFetchTodos(Result<[TodoState], FirestoreError>)
  case didFirestoreCRUD(Result<Bool, FirestoreError>)
}

struct TodoListEnvironment {
  let client: UserClient
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
      
    // firestore
    case .fetchTodos:
      return environment.client.fetchTodos()
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.didFetchTodos)
      
    case .createTodo:
      return environment.client.createTodo()
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.didFirestoreCRUD)
      
    case let .removeTodo(todo):
      return environment.client.removeTodo(todo)
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.didFirestoreCRUD)
      
    case let .updateTodo(todo):
      return environment.client.updateTodo(todo)
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.didFirestoreCRUD)
      
    case .clearCompleted:
      return environment.client.removeTodos(state.todos.filter(\.done))
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.didFirestoreCRUD)
      
    // results
    case let .didFetchTodos(.success(todos)):
      state.todos = IdentifiedArray(uniqueElements: todos)
      return .none
      
    case let .didFetchTodos(.failure(error)):
      state.error = error
      return .none
      
    case .didFirestoreCRUD(.success):
      return .none
      
    case let .didFirestoreCRUD(.failure(error)):
      state.error = error
      return .none      
    }
  }
)

extension TodoListState {
  static let defaultStore = Store(
    initialState: .init(),
    reducer: todoListReducer,
    environment: .init(client: .live, scheduler: .main)
  )
}
