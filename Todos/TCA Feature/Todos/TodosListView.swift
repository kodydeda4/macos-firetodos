//
//  TodosListView.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture

struct TodosListView: View {
    let store: Store<TodosList.State, TodosList.Action>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            List(viewStore.todos) { book in
                
                HStack {
                    Button(action: { viewStore.send(.toggleCompleted(book)) }) {
                        Image(systemName: book.completed ? "largecircle.fill.circle" : "circle")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button("remove") { viewStore.send(.removeBook(book)) }

                    VStack(alignment: .leading) {
                        Text(book.description)
                            .font(.headline)
//                        Text(book.author)
//                            .font(.subheadline)
//                        Text("\(book.numberOfPages) pages")
//                            .font(.subheadline)
                    }
                    .opacity(book.completed ? 0.25 : 1)
                }
            }
            .onAppear() {
                viewStore.send(.onAppear)
            }
            .toolbar {
                ToolbarItem {
                    Button("Add") { viewStore.send(.addBook) }
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
