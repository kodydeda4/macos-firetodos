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
  case createClearCompletedAlert
  case dismissAlert
  case attachListener
  case createTodo
  case removeTodo(TodoState)
  case updateTodo(TodoState)
  case clearCompleted
  case fetchTodosResult(Result<[TodoState], APIError>)
  case updateRemoteResult(Result<Never, APIError>)
  
  case crud(Result<Bool, APIError>)
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

    case .createClearCompletedAlert:
      state.alert = AlertState(
        title: TextState("Clear completed?"),
        primaryButton: .default(TextState("Okay"), action: .send(.clearCompleted)),
        secondaryButton: .cancel(TextState("Cancel"))
      )
      return .none
      
    case let .removeTodo(todo):
      return environment.todosClient.delete(todo)
        .mapError(APIError.init)
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.updateRemoteResult)

    case let .updateTodo(todo):
      return environment.todosClient.update(todo)
        .mapError(APIError.init)
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.updateRemoteResult)
      
    case let .updateRemoteResult(.failure(error)):
      state.error = error
      return .none
    
    case .dismissAlert:
      state.alert = nil
      return .none
      
    case .attachListener:
      return environment.todosClient.attachListener()
        .receive(on: environment.scheduler)
        .catchToEffect()
        .cancellable(id: EffectID())
        .map(TodoListAction.fetchTodosResult)
            
    case .createTodo:
      return environment.todosClient.create()
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.crud)
            
    case .clearCompleted:
      return environment.todosClient.deleteX(state.todos.filter(\.done))
        .mapError(APIError.init)
        .receive(on: environment.scheduler)
        .catchToEffect()
        .map(TodoListAction.updateRemoteResult)
      
    case let .fetchTodosResult(.success(todos)):
      state.todos = IdentifiedArray(uniqueElements: todos)
      return .none
      
    case let .fetchTodosResult(.failure(error)):
      state.error = error
      return .none
      
    // MARK: - CRUD
    case .crud(.success):
      return .none
      
    case let .crud(.failure(error)):
      state.error = error
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
