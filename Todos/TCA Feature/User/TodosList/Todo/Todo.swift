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
  let userID: String
  var timestamp = Date()
  var text: String = "Untitled"
  var done: Bool = false
}

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
        
  case let .setText(text):
    state.text = text
    return Effect(value: .updateRemote)
    
  case .setDone:
    state.done.toggle()
    return Effect(value: .updateRemote)
    
  case .delete:
    return environment.todosClient.remove(state)
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
      userID: "GxscCXP9odUQucq6A5cBXJEiTBd2",
      timestamp: Date(),
      text: "Untitled"
    ),
    reducer: todoReducer,
    environment: .init(
      todosClient: .live,
      scheduler: .main
    )
  )
}
