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
  @ServerTimestamp var timestamp: Date?
  var text: String = "Untitled"
  var done: Bool = false
  var userID: String? = Auth.auth().currentUser?.uid
}

enum TodoAction: Equatable {
  case toggleCompleted
  case deleteButonTapped
  case updateText(String)
}

let todoReducer = Reducer<TodoState, TodoAction, Void> { state, action, _ in
  switch action {
    
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
  static let defaultStore = Store(
    initialState: .init(),
    reducer: todoReducer,
    environment: ()
  )
}
