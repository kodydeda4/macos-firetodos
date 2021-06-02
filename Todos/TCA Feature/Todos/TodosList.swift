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

struct Todo: Equatable, Identifiable, Codable {
    @DocumentID var id: String?
    @ServerTimestamp var createdAt: Date?
    var description: String
    var completed: Bool = false
}

struct TodosList {
    struct State: Equatable {
        var todos = [Todo]()
        var error: Firestore.DBError?
    }
    
    enum Action: Equatable {
        case onAppear
        
        case fetchTodos
        case createTodo
        case remove(Todo)
        case toggleCompleted(Todo)
        case clearCompleted
        case updateTodoText(Todo, String)

        case didFetchTodos      (Result<[Todo], Firestore.DBError>)
        case didCreateTodo      (Result<Bool,   Firestore.DBError>)
        case didRemoveTodo      (Result<Bool,   Firestore.DBError>)
        case didRemoveCompleted (Result<Bool,   Firestore.DBError>)
        case didUpdateTodo      (Result<Bool,   Firestore.DBError>)
    }
    
    struct Environment {
        let db = Firestore.firestore()
        let collection = "todos"
        
        var fetchData: Effect<Action, Never> {
            db.fetchData(ofType: Todo.self, from: collection)
                .map(Action.didFetchTodos)
                .eraseToEffect()
        }
        
        func addTodo(_ todo: Todo) -> Effect<Action, Never> {
            db.add(todo, to: collection)
                .map(Action.didCreateTodo)
                .eraseToEffect()
        }
        
        func removeTodo(_ todo: Todo) -> Effect<Action, Never> {
            db.remove(todo.id!, from: collection)
                .map(Action.didRemoveTodo)
                .eraseToEffect()
        }
        
        func removeTodos(_ todos: [Todo]) -> Effect<Action, Never> {
            db.remove(todos.map(\.id!), from: collection)
                .map(Action.didRemoveTodo)
                .eraseToEffect()
        }
        
        func updateTodo(_ oldTodo: Todo, to newTodo: Todo) -> Effect<Action, Never> {
            db.set(oldTodo.id!, to: newTodo, in: collection)
                .map(Action.didUpdateTodo)
                .eraseToEffect()
        }
    }
}

extension TodosList {
    static let reducer = Reducer<State, Action, Environment>.combine(
        
        Reducer { state, action, environment in
            switch action {
            
            case .onAppear:
                return Effect(value: .fetchTodos)
                
            case .fetchTodos:
                return environment.fetchData
                
            case .createTodo:
                return environment.addTodo(Todo.init(description: "Title"))
                
            case let .remove(book):
                return environment.removeTodo(book)
                
            case let .toggleCompleted(book):
                var book2 = book
                book2.completed.toggle()
                
                return environment.updateTodo(book, to: book2)
                
            case .clearCompleted:
                return environment.removeTodos(state.todos.filter(\.completed))

            // Result
            case let .didFetchTodos(.success(books)):
                state.todos = books
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
                
            case let .updateTodoText(todo, text):
                var newTodo = todo
                newTodo.description = text
                
                return environment.updateTodo(todo, to: newTodo)
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
