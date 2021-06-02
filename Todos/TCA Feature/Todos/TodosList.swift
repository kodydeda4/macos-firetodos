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
        var error: Firestore.DBError?
    }
    
    enum Action: Equatable {
        case onAppear
        case fetchTodos
        case todos(index: Int, action: Todo.Action)
        case createTodo
        case removeTodo(Todo.State)
        case toggleCompleted(Todo.State)
        case updateTodoText(Todo.State, String)
        case clearCompleted
        
        // results
        case didFetchTodos(Result<[Todo.State], Firestore.DBError>)
        case didCreateTodo(Result<Bool, Firestore.DBError>)
        case didRemoveTodo(Result<Bool, Firestore.DBError>)
        case didRemoveCompleted(Result<Bool, Firestore.DBError>)
        case didUpdateTodo(Result<Bool, Firestore.DBError>)
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
        
        func updateTodo(_ oldTodo: Todo.State, to newTodo: Todo.State) -> Effect<Action, Never> {
            db.set(oldTodo.id!, to: newTodo, in: collection)
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
                return .none
                
            case .createTodo:
                return environment.addTodo(Todo.State())
                
            case let .removeTodo(book):
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

// MARK:- TodosListView

import SwiftUI
import ComposableArchitecture

struct TodosListView: View {
    let store: Store<TodosList.State, TodosList.Action>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                ForEachStore(store.scope(
                    state: \.todos,
                    action: TodosList.Action.todos(index:action:)
                ), content: TodoView.init)
            }
            .onAppear() {
                viewStore.send(.onAppear)
            }
            .toolbar {
                ToolbarItem {
                    Button("Add") { viewStore.send(.createTodo) }
                }
                ToolbarItem {
                    Button("Clear Completed") {
                        viewStore.send(.clearCompleted)
                    }
                }
            }
        }
    }
}

struct TodosListView_Previews: PreviewProvider {
    static var previews: some View {
        TodosListView(store: TodosList.defaultStore)
    }
}
