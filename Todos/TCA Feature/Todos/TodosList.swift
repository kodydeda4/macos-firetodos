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
        
        case fetchBooks
        case addBook
        case removeBook(Todo)
        case toggleCompleted(Todo)
        case clearCompleted

        case didFetchBooks  (Result<[Todo], Firestore.DBError>)
        case didAddBook     (Result<Bool,   Firestore.DBError>)
        case didRemoveBook  (Result<Bool,   Firestore.DBError>)
        case didRemoveBooks (Result<Bool,   Firestore.DBError>)
        case didUpdateBook  (Result<Bool,   Firestore.DBError>)
    }
    
    struct Environment {
        let db = Firestore.firestore()
        let collection = "todos"
        
        var fetchData: Effect<Action, Never> {
            db.fetchData(ofType: Todo.self, from: collection)
                .map(Action.didFetchBooks)
                .eraseToEffect()
        }
        
        func addBook(_ book: Todo) -> Effect<Action, Never> {
            db.add(book, to: collection)
                .map(Action.didAddBook)
                .eraseToEffect()
        }
        
        func removeBook(_ book: Todo) -> Effect<Action, Never> {
            db.remove(book.id!, from: collection)
                .map(Action.didRemoveBook)
                .eraseToEffect()
        }
        
        func removeBooks(_ books: [Todo]) -> Effect<Action, Never> {
            db.remove(books.map(\.id!), from: collection)
                .map(Action.didRemoveBook)
                .eraseToEffect()
        }
        
        func updateBook(_ oldBook: Todo, to newBook: Todo) -> Effect<Action, Never> {
            db.set(oldBook.id!, to: newBook, in: collection)
                .map(Action.didUpdateBook)
                .eraseToEffect()
        }
    }
}

extension TodosList {
    static let reducer = Reducer<State, Action, Environment>.combine(
        
        Reducer { state, action, environment in
            switch action {
            
            case .onAppear:
                return Effect(value: .fetchBooks)
                
            case .fetchBooks:
                return environment.fetchData
                
            case .addBook:
                return environment.addBook(Todo(description: "Title"))
                
            case let .removeBook(book):
                return environment.removeBook(book)
                
            case let .toggleCompleted(book):
                var book2 = book
                book2.completed.toggle()
                
                return environment.updateBook(book, to: book2)
                
            case .clearCompleted:
                return environment.removeBooks(state.todos.filter(\.completed))

            // Result
            case let .didFetchBooks(.success(books)):
                state.todos = books
                return .none
                
            case .didAddBook         (.success),
                 .didRemoveBook      (.success),
                 .didRemoveBooks     (.success),
                 .didUpdateBook      (.success):
                return .none

            case let .didFetchBooks  (.failure(error)),
                 let .didAddBook     (.failure(error)),
                 let .didRemoveBook  (.failure(error)),
                 let .didRemoveBooks (.failure(error)),
                 let .didUpdateBook  (.failure(error)):
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
