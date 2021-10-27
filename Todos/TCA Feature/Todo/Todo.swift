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

enum TodoAction: BindableAction, Equatable {
  case binding(BindingAction<TodoState>)
  case toggleCompleted
  case deleteButonTapped
  case updateText(String)
}

let todoReducer = Reducer<TodoState, TodoAction, Void> { state, action, _ in
  switch action {
    
  case .binding:
    return .none
    
  case .toggleCompleted:
    state.done.toggle()
    return .none
    
  case .deleteButonTapped:
    return .none
    
  case let .updateText(text):
    state.text = text
    return .none
  }
}

extension TodoState {
  static let defaultStore = Store<TodoState, TodoAction>(
    initialState: .init(
      timestamp: Date(),
      userID: "GxscCXP9odUQucq6A5cBXJEiTBd2",
      text: "Untitled"
    ),
    reducer: todoReducer,
    environment: ()
  )
}
