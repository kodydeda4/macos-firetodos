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
import AuthenticationServices

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
        
        // SignIn
        case signInWithEmailButtonTapped
        case signInAnonymouslyButtonTapped
        case signInWithAppleButtonTapped(Result<ASAuthorization, FirestoreError>)

        
        // Results
        case signInWithEmailButtonTappedResult(Result<Bool, FirestoreError>)
        case signInAnonymouslyButtonTappedResult(Result<Bool, FirestoreError>)
        case signInWithAppleButtonTappedResult(Result<Bool, FirestoreError>)

        case signOut
    }
    
    struct Environment {
        func signIn(email: String, password: String) -> Effect<Action, Never> {
            Firestore.signIn(email, password)
                .map(Action.signInWithEmailButtonTappedResult)
                .eraseToEffect()
        }
        
        var signInAnonymously: Effect<Action, Never> {
            Firestore.signInAnonymously()
                .map(Action.signInAnonymouslyButtonTappedResult)
                .eraseToEffect()
        }
        
        func signInWithApple(result: Result<ASAuthorization, FirestoreError>) -> Effect<Action, Never> {
            Firestore.handleAppleSignInResult(result: result)
                .map(Action.signInWithAppleButtonTappedResult)
                .eraseToEffect()
        }
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
            
        case .signInWithEmailButtonTapped:
            return environment.signIn(email: state.email, password: state.password)
            
        case .signInWithEmailButtonTappedResult(.success):
            state.signedIn.toggle()
            return .none
            
        case let .signInWithEmailButtonTappedResult(.failure(error)):
            state.error = error
            state.attempted = true
            return .none
            
        case .signInAnonymouslyButtonTapped:
            return environment.signInAnonymously
            
        case .signInAnonymouslyButtonTappedResult(.success):
            state.signedIn.toggle()
            return .none
            
        case let .signInAnonymouslyButtonTappedResult(.failure(error)):
            state.error = error
            state.attempted = true
            return .none
            
        case .signOut:
            state.signedIn = false
            return .none

        case let .signInWithAppleButtonTapped(result):
            return environment.signInWithApple(result: result)
            
        case .signInWithAppleButtonTappedResult(.success):
            state.signedIn.toggle()
            return .none
            
        case let .signInWithAppleButtonTappedResult(.failure(error)):
            state.error = error
            state.attempted = true
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
