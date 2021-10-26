//
//  TodosList.swift
//  Todos
//
//  Created by Kody Deda on 6/1/21.
//

import Combine
import ComposableArchitecture

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift


struct TodoListState: Equatable {
  var todos: [TodoState] = []
  var error: FirestoreError?
  var alert: AlertState<TodoListAction>?
}

enum TodoListAction: Equatable {
  case todos(index: Int, action: TodoAction)
  
  // firestore
  case fetchTodos
  case createTodo
  case removeTodo(TodoState)
  case updateTodo(TodoState)
  case clearCompleted
  
  // results
  case didFetchTodos     (Result<[TodoState], FirestoreError>)
  case didCreateTodo     (Result<Bool, FirestoreError>)
  case didRemoveTodo     (Result<Bool, FirestoreError>)
  case didClearCompleted (Result<Bool, FirestoreError>)
  case didUpdateTodo     (Result<Bool, FirestoreError>)
}

struct TodoListEnvironment {
  let db = Firestore.firestore()
  let collection = "todos"
  let userID = Auth.auth().currentUser!.uid
  
  var fetchData: Effect<TodoListAction, Never> {
    db.fetchData(ofType: TodoState.self, from: collection, for: userID)
      .map(TodoListAction.didFetchTodos)
      .eraseToEffect()
  }
  
  func createTodo(_ todo: TodoState) -> Effect<TodoListAction, Never> {
    db.add(todo, to: collection)
      .map(TodoListAction.didCreateTodo)
      .eraseToEffect()
  }
  
  func removeTodo(_ todo: TodoState) -> Effect<TodoListAction, Never> {
    db.remove(todo.id!, from: collection)
      .map(TodoListAction.didRemoveTodo)
      .eraseToEffect()
  }
  
  func clearCompleted(_ todos: [TodoState]) -> Effect<TodoListAction, Never> {
    db.remove(todos.map(\.id!), from: collection)
      .map(TodoListAction.didRemoveTodo)
      .eraseToEffect()
  }
  
  func updateTodo(_ todo: TodoState) -> Effect<TodoListAction, Never> {
    db.set(todo.id!, to: todo, in: collection)
      .map(TodoListAction.didUpdateTodo)
      .eraseToEffect()
  }
}

let todoListReducer = Reducer<TodoListState, TodoListAction, TodoListEnvironment>.combine(
  todoReducer.forEach(
    state: \.todos,
    action: /TodoListAction.todos(index:action:),
    environment: { _ in () }
  ),
  
  Reducer { state, action, environment in
    switch action {
      
    case let .todos(index, action):
      return Effect(value: .updateTodo(state.todos[index]))
      
      // firestore
    case .fetchTodos:
      return environment.fetchData
      
    case .createTodo:
      return environment.createTodo(TodoState())
      
    case let .removeTodo(todo):
      return environment.removeTodo(todo)
      
    case let .updateTodo(todo):
      return environment.updateTodo(todo)
      
    case .clearCompleted:
      return environment.clearCompleted(state.todos.filter(\.done))
      
      // results
    case let .didFetchTodos(.success(todos)):
      state.todos = todos
      return .none
      
    case .didCreateTodo        (.success),
        .didRemoveTodo         (.success),
        .didClearCompleted     (.success),
        .didUpdateTodo         (.success):
      
      return .none
      
    case let .didFetchTodos     (.failure(error)),
      let .didCreateTodo     (.failure(error)),
      let .didRemoveTodo     (.failure(error)),
      let .didClearCompleted (.failure(error)),
      let .didUpdateTodo     (.failure(error)):
      
      state.error = error
      return .none
      
      
    }
  }
)

extension TodoListState {
  static let defaultStore = Store(
    initialState: .init(),
    reducer: todoListReducer,
    environment: .init()
  )
}
