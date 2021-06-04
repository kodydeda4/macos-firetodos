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
        case signInButtonTapped_Anonymous
        case signInButtonTapped_Email
        case signInButtonTapped_Apple(ASAuthorizationAppleIDCredential)

        
        // Results
        case signInResult_Anonymous (Result<Bool, FirestoreError>)
        case signInResult_Email     (Result<Bool, FirestoreError>)
        case signInResult_Apple     (Result<Bool, FirestoreError>)

        case signOut
    }
    
    struct Environment {
        var signIn: Effect<Action, Never> {
            Firestore.signIn()
                .map(Action.signInResult_Anonymous)
                .eraseToEffect()
        }

        func signIn(email: String, password: String) -> Effect<Action, Never> {
            Firestore.signIn(email, password)
                .map(Action.signInResult_Email)
                .eraseToEffect()
        }
        
        func signIn(using appleIDCredential: ASAuthorizationAppleIDCredential) -> Effect<Action, Never> {
            Firestore.signIn(using: appleIDCredential)
                .map(Action.signInResult_Apple)
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
            
        case .signInButtonTapped_Email:
            return environment.signIn(email: state.email, password: state.password)
            
        case .signInButtonTapped_Anonymous:
            return environment.signIn
            
        case .signOut:
            state.signedIn = false
            return .none

        case let .signInButtonTapped_Apple(appleIDCredential):
            return environment.signIn(using: appleIDCredential)

            
        // Results
        case .signInResult_Anonymous(.success):
            state.signedIn.toggle()
            return .none
            
        case let .signInResult_Anonymous(.failure(error)):
            state.error = error
            state.attempted = true
            return .none

        case .signInResult_Email(.success):
            state.signedIn.toggle()
            return .none
            
        case let .signInResult_Email(.failure(error)):
            state.error = error
            state.attempted = true
            return .none

        case .signInResult_Apple(.success):
            state.signedIn.toggle()
            return .none
            
        case let .signInResult_Apple(.failure(error)):
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
