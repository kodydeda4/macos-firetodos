//
//  Todo.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture
import Firebase
import FirebaseFirestoreSwift

struct TodoState: Equatable, Identifiable, Codable {
  @DocumentID var id: String?
  let timestamp: Date
  let userID: String
  var text: String
  var done: Bool = false
}

//enum TodoAction: BindableAction, Equatable {
//  case binding(BindingAction<TodoState>)
enum TodoAction: Equatable {
  case setText(String)
  case setDone
  case delete
  
  case updateRemote
  case didUpdateRemote(Result<Never, APIError>)
}

struct TodoEnvironment {
  let todosClient: TodosClient
  let scheduler: AnySchedulerOf<DispatchQueue>
}

let todoReducer = Reducer<TodoState, TodoAction, TodoEnvironment> { state, action, environment in
  switch action {
    
//  case .binding:
//    return .none
    
  case let .setText(text):
    state.text = text
    return Effect(value: .updateRemote)
    
  case .setDone:
    state.done.toggle()
    return Effect(value: .updateRemote)
    
  case .delete:
    return environment.todosClient.delete(state)
      .receive(on: environment.scheduler)
      .catchToEffect()
      .map(TodoAction.didUpdateRemote)
    
  case .updateRemote:
    return environment.todosClient.update(state)
      .receive(on: environment.scheduler)
      .catchToEffect()
      .map(TodoAction.didUpdateRemote)
    
  case let .didUpdateRemote(.failure(error)):
    print(error.localizedDescription)
    return .none
  }
}
.debug()

extension Store where State == TodoState, Action == TodoAction {
  static let `default` = Store(
    initialState: .init(
      timestamp: Date(),
      userID: "GxscCXP9odUQucq6A5cBXJEiTBd2",
      text: "Untitled"
    ),
    reducer: todoReducer,
    environment: .init(
      todosClient: .live,
      scheduler: .main
    )
  )
}
