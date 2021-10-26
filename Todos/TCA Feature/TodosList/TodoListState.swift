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
  case didFetchTodos     (Result<[TodoState], FirestoreError>)
  case didCreateTodo     (Result<Bool, FirestoreError>)
  case didRemoveTodo     (Result<Bool, FirestoreError>)
  case didClearCompleted (Result<Bool, FirestoreError>)
  case didUpdateTodo     (Result<Bool, FirestoreError>)
}

struct UserClient {
  let fetchTodos: () -> Effect<[TodoState], FirestoreError>
  let createTodo: ()          -> Effect<Bool, FirestoreError>
  let updateTodo: (TodoState) -> Effect<Bool, FirestoreError>
  let removeTodo: (TodoState) -> Effect<Bool, FirestoreError>
}

extension UserClient {
  static let live = UserClient(
    fetchTodos: {
      let rv = PassthroughSubject<[TodoState], FirestoreError>()
      Firestore.firestore()
        .collection("todos")
        .whereField("userID", isEqualTo: Auth.auth().currentUser!.uid)
        .addSnapshotListener { querySnapshot, error in
          if let values = querySnapshot?.documents.compactMap({ snapshot in try? snapshot.data(as: TodoState.self) }) {
            rv.send(values)
          } else if let error = error {
            rv.send(completion: .failure(FirestoreError(error)))
          }
        }
      return rv.eraseToEffect()
    },
    createTodo: {
      let rv = PassthroughSubject<Bool, FirestoreError>()
      
      do {
        let _ = try Firestore.firestore()
          .collection("todos")
          .addDocument(from: TodoState())
        
        rv.send(true)
      }
      catch {
        rv.send(completion: .failure(FirestoreError(error)))
      }
      
      return rv.eraseToEffect()
    },
    updateTodo: { todo in
      let rv = PassthroughSubject<Bool, FirestoreError>()
      do {
        try Firestore.firestore()
          .collection("todos")
          .document(todo.id!)
          .setData(from: todo)
        rv.send(true)
      }
      catch {
        print(error)
        rv.send(completion: .failure(FirestoreError(error)))
      }
      return rv.eraseToEffect()
    },
    removeTodo: { todo in
      let rv = PassthroughSubject<Bool, FirestoreError>()
      
      Firestore.firestore().collection("todos").document(todo.id!).delete { error in
        if let error = error {
          rv.send(completion: .failure(FirestoreError(error)))
        } else {
          rv.send(true)
        }
      }
      return rv.eraseToEffect()
    }
  )
}

struct TodoListEnvironment {
  let client: UserClient = .live
  let mainQueue: AnySchedulerOf<DispatchQueue> = .main
//  func clearCompleted(_ todos: [TodoState]) -> Effect<TodoListAction, Never> {
//    db.remove(todos.map(\.id!), from: collection)
//      .map(TodoListAction.didRemoveTodo)
//      .eraseToEffect()
//  }
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
      
      switch action {
      case .deleteButonTapped:
        return environment.client.removeTodo(todo)
          .receive(on: environment.mainQueue)
          .catchToEffect()
          .map(TodoListAction.didRemoveTodo)
        
      default:
        return Effect(value: .updateTodo(todo))
      }
      
    // firestore
    case .fetchTodos:
      return environment.client.fetchTodos()
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(TodoListAction.didFetchTodos)
      
    case .createTodo:
      return environment.client.createTodo()
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(TodoListAction.didCreateTodo)
      
    case let .removeTodo(todo):
      return environment.client.removeTodo(todo)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(TodoListAction.didRemoveTodo)

    case let .updateTodo(todo):
      return environment.client.updateTodo(todo)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(TodoListAction.didUpdateTodo)

    case .clearCompleted:
      return .none // environment.clearCompleted(state.todos.filter(\.done))
      
    // results
    case let .didFetchTodos(.success(todos)):
      state.todos = IdentifiedArray(uniqueElements: todos)
      return .none
      
    case .didCreateTodo        (.success),
        .didRemoveTodo         (.success),
        .didClearCompleted     (.success),
        .didUpdateTodo         (.success):
      
      return .none
      
    case let .didFetchTodos  (.failure(error)),
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
