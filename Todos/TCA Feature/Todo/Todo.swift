//
//  Todo.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture

// 57 minutes
// https://www.youtube.com/watch?v=HDde7TqKCpk&t=2051s

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Todo {
    struct State: Equatable, Identifiable, Codable {
        @DocumentID var id: String?
        @ServerTimestamp var createdAt: Date?
        var description: String = "Untitled"
        var completed: Bool = false
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
            state.completed.toggle()
            return .none
            
        case let .updateText(text):
            state.description = text
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
