//
//  Root.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture

struct Root {
    struct State: Equatable {
        var todosList = TodosList.State()
    }
    
    enum Action: Equatable {
        case todosList(TodosList.Action)
    }
    
    struct Environment {

    }
}

extension Root {
    static let reducer = Reducer<State, Action, Environment>.combine(
        TodosList.reducer.pullback(
            state: \.todosList,
            action: /Action.todosList,
            environment: { _ in .init() }
        ),
        Reducer { state, action, environment in
            switch action {
            default: return .none
            }
        }
    )
}

extension Root {
    static let defaultStore = Store(
        initialState: .init(),
        reducer: reducer,
        environment: .init()
    )
}
