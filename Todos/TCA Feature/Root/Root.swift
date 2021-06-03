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
        var authentication = Authentication.State()
        var todosList = TodosList.State()
    }
    
    enum Action: Equatable {
        case authentication(Authentication.Action)
        case todosList(TodosList.Action)
    }
}

extension Root {
    static let reducer = Reducer<State, Action, Void>.combine(
        Authentication.reducer.pullback(
            state: \.authentication,
            action: /Action.authentication,
            environment: { _ in .init() }
        ),
        TodosList.reducer.pullback(
            state: \.todosList,
            action: /Action.todosList,
            environment: { _ in .init() }
        ),
        Reducer { state, action, _ in
            switch action {
            
            case let .todosList(subaction):
                switch subaction {

                case .signOutButtonTapped:
                    return Effect(value: .authentication(.signOut))

                default:
                    break
                }
                return .none
                
            default:
                return .none
            }
        }
    )
    .debug()
}

extension Root {
    static let defaultStore = Store(
        initialState: .init(),
        reducer: reducer,
        environment: ()
    )
}

