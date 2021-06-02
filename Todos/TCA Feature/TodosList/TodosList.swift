//
//  TodosList.swift
//  Todos
//
//  Created by Kody Deda on 6/1/21.
//

import Combine
import ComposableArchitecture
import FirebaseFirestore
import FirebaseFirestoreSwift

struct TodosList {
    struct State: Equatable {
        var todos: [Todo.State] = []
        var error: FirestoreError?
    }
    
    enum Action: Equatable {
        case onAppear
        case fetchTodos
        case todos(index: Int, action: Todo.Action)
        
        case createTodo
        case removeTodo(Todo.State)
        case updateTodo(Todo.State)
        case clearCompleted
        
        // results
        case didFetchTodos      (Result<[Todo.State], FirestoreError>)
        case didCreateTodo      (Result<Bool, FirestoreError>)
        case didRemoveTodo      (Result<Bool, FirestoreError>)
        case didRemoveCompleted (Result<Bool, FirestoreError>)
        case didUpdateTodo      (Result<Bool, FirestoreError>)
    }
    
    struct Environment {
        let db = Firestore.firestore()
        let collection = "todos"
        
        var fetchData: Effect<Action, Never> {
            db.fetchData(ofType: Todo.State.self, from: collection)
                .map(Action.didFetchTodos)
                .eraseToEffect()
        }
        
        func addTodo(_ todo: Todo.State) -> Effect<Action, Never> {
            db.add(todo, to: collection)
                .map(Action.didCreateTodo)
                .eraseToEffect()
        }
        
        func removeTodo(_ todo: Todo.State) -> Effect<Action, Never> {
            db.remove(todo.id!, from: collection)
                .map(Action.didRemoveTodo)
                .eraseToEffect()
        }
        
        func removeTodos(_ todos: [Todo.State]) -> Effect<Action, Never> {
            db.remove(todos.map(\.id!), from: collection)
                .map(Action.didRemoveTodo)
                .eraseToEffect()
        }
        
        func updateTodo(_ todo: Todo.State) -> Effect<Action, Never> {
            db.set(todo.id!, to: todo, in: collection)
                .map(Action.didUpdateTodo)
                .eraseToEffect()
        }
    }
}

extension TodosList {
    static let reducer = Reducer<State, Action, Environment>.combine(
        Todo.reducer.forEach(
            state: \.todos,
            action: /Action.todos(index:action:),
            environment: { _ in () }
        ),
        
        Reducer { state, action, environment in
            switch action {
            
            case .onAppear:
                return Effect(value: .fetchTodos)
                
            case .fetchTodos:
                return environment.fetchData
                
            case let .todos(index, action):
                return Effect(value: .updateTodo(state.todos[index]))
                
            case .createTodo:
                return environment.addTodo(Todo.State())
                
            case let .removeTodo(todo):
                return environment.removeTodo(todo)
                
            case let .updateTodo(todo):
                return environment.updateTodo(todo)

            case .clearCompleted:
                return environment.removeTodos(state.todos.filter(\.completed))

            // Result
            case let .didFetchTodos(.success(todos)):
                state.todos = todos
                return .none
                
            case .didCreateTodo          (.success),
                 .didRemoveTodo          (.success),
                 .didRemoveCompleted     (.success),
                 .didUpdateTodo          (.success):
                return .none

            case let .didFetchTodos      (.failure(error)),
                 let .didCreateTodo      (.failure(error)),
                 let .didRemoveTodo      (.failure(error)),
                 let .didRemoveCompleted (.failure(error)),
                 let .didUpdateTodo      (.failure(error)):
                state.error = error
                return .none
            }
        }
        .debug()
    )
}

extension TodosList {
    static let defaultStore = Store(
        initialState: .init(),
        reducer: reducer,
        environment: .init()
    )
}
