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
        var signedIn = false
        var attempted = false
        var error: FirestoreError?
        var email = String.init()
        var password = String.init()
    }
    
    enum Action: Equatable {
        case updateEmail(String)
        case updatePassword(String)
        case loginButtonTapped
        case signInEmailResult(Result<Bool, FirestoreError>)
        
        case signInAnonymouslyButtonTapped
        case signInAnonymouslyResult(Result<Bool, FirestoreError>)
        case signOut
//        case signOutResult(Result<Bool, FirestoreError>)
        
    }
    
    struct Environment {
        func signIn(email: String, password: String) -> Effect<Action, Never> {
            Firestore.signIn(email, password)
                .map(Action.signInEmailResult)
                .eraseToEffect()
        }
        
        var signInAnonymously: Effect<Action, Never> {
            Firestore.signInAnonymously()
                .map(Action.signInAnonymouslyResult)
                .eraseToEffect()
        }
        
//        var signOut: Effect<Action, Never> {
//            Firestore.signOut()
//                .map(Action.signOutResult)
//                .eraseToEffect()
//        }
    }
}

extension Authentication {
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        
        switch action {
        
        case let .updateEmail(value):
            state.email = value
            return .none
            
        case let .updatePassword(value):
            state.password = value
            return .none
            
        case .loginButtonTapped:
            return environment.signIn(email: state.email, password: state.password)
            
        case .signInAnonymouslyButtonTapped:
            return environment.signInAnonymously
            
        case .signOut:
            state.signedIn = false
            return .none
            
        // result
        case .signInEmailResult           (.success),
             .signInAnonymouslyResult     (.success):
            state = Authentication.State()
            state.signedIn.toggle()
            return .none
            
        case let .signInAnonymouslyResult (.failure(error)),
             let .signInEmailResult       (.failure(error)):
            state = Authentication.State()
            state.signedIn.toggle()
            return .none

        }
    }
}

extension Authentication {
    static let defaultStore = Store(
        initialState: .init(),
        reducer: reducer,
        environment: .init()
    )
}
