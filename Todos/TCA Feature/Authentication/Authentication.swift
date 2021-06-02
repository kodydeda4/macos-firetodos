//
//  UserAuthentication.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture
import Firebase
import Combine

struct Authentication {
    struct State: Equatable {
        var email = ""
        var password = ""
        var loggedIn = false
        var error: FirestoreError?
        var failedLoginAttempt = false
    }
    
    enum Action: Equatable {
        case updateEmail(String)
        case updatePassword(String)
        case loginButtonTapped
        case loginButtonTappedResult(Result<Bool, FirestoreError>)
    }
    
    struct Environment {
        func signIn(email: String, password: String) -> Effect<Action, Never> {
            Firestore.signIn(email, password)
                .map(Action.loginButtonTappedResult)
                .eraseToEffect()
        }
    }
}

extension Authentication {
    static let reducer = Reducer<State, Action, Environment>.combine(
        // pullbacks
        Reducer { state, action, environment in
            switch action {
            
            case let .updateEmail(value):
                state.email = value
                return .none
                
            case let .updatePassword(value):
                state.password = value
                return .none
                
            case .loginButtonTapped:
                return environment.signIn(email: state.email, password: state.password)

            case .loginButtonTappedResult(.success):
                state.loggedIn.toggle()
                return .none
                
            case let .loginButtonTappedResult(.failure(error)):
                state.error = error
                state.failedLoginAttempt = true
                return .none
            }
        }
    )
}

extension Authentication {
    static let defaultStore = Store(
        initialState: .init(),
        reducer: reducer,
        environment: .init()
    )
}
