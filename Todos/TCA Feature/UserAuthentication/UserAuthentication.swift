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

struct UserAuthentication {
    struct State: Equatable {
        var email = ""
        var password = ""
        var loggedIn = false
        var error: Firestore.DBError?
    }
    
    enum Action: Equatable {
        case updateEmail(String)
        case updatePassword(String)
        case loginButtonTapped
        case loginButtonTappedResult(Result<Bool, Firestore.DBError>)
    }
    
    struct Environment {
        func auth(email: String, password: String) -> AnyPublisher<Result<Bool, Firestore.DBError>, Never> {
            let rv = PassthroughSubject<Result<Bool, Firestore.DBError>, Never>()
            
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                switch error {
                case .none:
                    rv.send(.success(true))
                case .some:
                    rv.send(.failure(.login))
                }
            }
            
            return rv.eraseToAnyPublisher()
        }
    }
}

extension UserAuthentication {
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
                return environment.auth(email: state.email, password: state.password)
                    .map(Action.loginButtonTappedResult)
                    .eraseToEffect()

            case .loginButtonTappedResult(.success):
                state.loggedIn.toggle()
                return .none
                
            case let .loginButtonTappedResult(.failure(error)):
                state.error = error
                return .none
            }
        }
    )
}

extension UserAuthentication {
    static let defaultStore = Store(
        initialState: .init(),
        reducer: reducer,
        environment: .init()
    )
}
