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

struct Todo {
  struct State: Equatable, Identifiable, Codable {
    @DocumentID var id: String?
    @ServerTimestamp var timestamp: Date?
    var text: String = "Untitled"
    var done: Bool = false
    var userID: String? = Auth.auth().currentUser?.uid
  }
  
  enum Action: Equatable {
    case toggleCompleted
    case updateText(String)
  }
}

extension Todo {
  static let reducer = Reducer<State, Action, Void> { state, action, _ in
    switch action {
      
    case .toggleCompleted:
      state.done.toggle()
      return .none
      
    case let .updateText(text):
      state.text = text
      return .none
    }
  }
}

extension Todo {
  static let defaultStore = Store(
    initialState: .init(),
    reducer: reducer,
    environment: ()
  )
}
